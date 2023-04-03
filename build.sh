#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $0 [-f|--force] <ubuntu-version> hipsycl|dpcpp <git-ref>" >&2
    echo "       $0 [-f|--force] <ubuntu-version> computecpp <version>" >&2
    exit 1
}

ARGS=$(getopt --options="f" --longoptions="force" --name "$0" -- "$@") || usage
eval set -- "$ARGS"

unset FORCE
while true; do
    case "$1" in
        -f | --force) FORCE=yes; shift;;
        --) shift; break;;
        *) echo "Unexpected argument \"$1\"" >&2; usage;;
    esac
done

if [ $# -ne 3 ]; then usage; fi
UBUNTU="$1"
SYCL="$2"
REF="$3"

build-intel-compute-rt() {
    cp -r common intel-compute-rt
    docker build intel-compute-rt \
        --build-arg UBUNTU="$UBUNTU" \
        --build-arg INTEL_COMPUTE_RT="$INTEL_COMPUTE_RT" \
        --build-arg INTEL_IGC="$INTEL_IGC" \
        --tag "intel-compute-rt:$INTEL_COMPUTE_RT-ubuntu$UBUNTU" >&2
}

build-cuda-dist-upgrade() {
    if [ "$UBUNTU" != 23.04 ]; then
        echo "I don't know the codename of Ubuntu $UBUNTU"
        exit 1
    fi

    UBUNTU_BASE=22.04
    FROM_CODENAME=jammy
    TO_CODENAME=lunar

    docker build cuda-dist-upgrade \
        --build-arg UBUNTU_BASE="$UBUNTU_BASE" \
        --build-arg CUDA="$CUDA" \
        --build-arg FROM_CODENAME="$FROM_CODENAME" \
        --build-arg TO_CODENAME="$TO_CODENAME" \
        --tag nvidia/cuda:${CUDA}-devel-ubuntu${UBUNTU}
}

unset CUDA
unset INTEL_COMPUTE_RT
unset INTEL_IGC
if [ "$SYCL" == hipsycl ]; then
    case "$UBUNTU" in
        20.04) CUDA=11.0.3;;
        22.04) CUDA=11.8.0;;
        23.04) CUDA=12.1.0; build-cuda-dist-upgrade;;
        *) echo "I don't know which CUDA version to select for Ubuntu $UBUNTU" >&2; exit 1;;
    esac
else
    INTEL_COMPUTE_RT=22.31.23852
    INTEL_IGC=1.0.11485
    build-intel-compute-rt
fi

ROOT_DIR="$(readlink -f "$(dirname "$0")")"
SYCL_DIR="$ROOT_DIR/$SYCL"

TMP_DIR="$ROOT_DIR/tmp"
mkdir -p "$TMP_DIR"
SYCL_TAGS_FILE="$TMP_DIR/sycl-image-tags"

build-sycl-from-source() {
    set -eu -o pipefail

    GIT_REMOTE="$1"

    rm -rf install/opt
    mkdir -p install/opt

    SRC_DIR="$TMP_DIR/$SYCL"
    if [ -e "$SRC_DIR" ]; then
        cd "$SRC_DIR"
        git fetch --all >&2
    else
        git clone "$GIT_REMOTE" "$SRC_DIR" >&2
        cd "$SRC_DIR"
    fi

    COMMIT_ID=$(git rev-parse "remotes/origin/$REF" 2>/dev/null) \
        || COMMIT_ID=$(git rev-parse "tags/$REF" 2>/dev/null) \
        || COMMIT_ID=$(grep '^[0-9a-f]\+$' <<< "$REF") \
        || (echo "Error: cannot resolve Git ref $REF" >&2; exit 1)

    git -c advice.detachedHead=false checkout --force "$COMMIT_ID" >&2
    git clean -fdx >&2
    git submodule update --init --recursive >&2
    VERSION="Ubuntu ${UBUNTU} ${CUDA+CUDA $CUDA }${INTEL_COMPUTE_RT+Intel Compute Runtime $INTEL_COMPUTE_RT }$SYCL $REF @ $(git log --format=format:"%H | %ci" -1)"

    cd "$SYCL_DIR"
    echo "Building $VERSION" >&2

    BUILD_IMAGE_TAG="$SYCL-build/ubuntu$UBUNTU"
    BASE_TAG="$SYCL:ubuntu$UBUNTU"
    COMMIT_TAG="$BASE_TAG-${COMMIT_ID:0:8}"
    GIT_REF_TAG="$BASE_TAG-$(echo -n "$REF" | tr -sc 'A-Za-z0-9.' '-')"

    EXISTING_IMAGE_ID="$(docker images -f "reference=$COMMIT_TAG" -q)"
    if [ -n "$EXISTING_IMAGE_ID" ] && ! [ -n "${FORCE+x}" ]; then
        docker tag "$COMMIT_TAG" "$GIT_REF_TAG" >&2
        echo "Image $GIT_REF_TAG (aka $EXISTING_IMAGE_ID) already exists" >&2
        echo -e "$COMMIT_TAG\n$GIT_REF_TAG" > "$SYCL_TAGS_FILE"
        exit 0
    fi

    # We use a named volume for ccache.
    # The volume is managed by Docker and persists between containers.
    CCACHE_VOLUME="ccache-$SYCL"

    echo "Creating SYCL build container ($BUILD_IMAGE_TAG)" >&2
    cp -r ../common build >&2
    docker build build \
        --build-arg=UBUNTU="$UBUNTU" \
        ${CUDA+"--build-arg=CUDA=$CUDA"} \
        ${INTEL_COMPUTE_RT+"--build-arg=INTEL_COMPUTE_RT=$INTEL_COMPUTE_RT"} \
        ${INTEL_IGC+"--build-arg=INTEL_IGC=$INTEL_IGC"} \
        --tag "$BUILD_IMAGE_TAG" >&2
    BUILD_IMAGE_CONTAINER_ID=$(docker create \
        --mount "type=bind,src=$SRC_DIR,dst=/src" \
        --mount "type=volume,src=$CCACHE_VOLUME,dst=/ccache" \
        "$BUILD_IMAGE_TAG"
    )

    function cleanup {
        echo "Removing SYCL build container ($BUILD_IMAGE_CONTAINER_ID)" >&2
        docker rm "$BUILD_IMAGE_CONTAINER_ID" >&2
    }
    trap cleanup EXIT

    echo "Starting SYCL build container ($BUILD_IMAGE_CONTAINER_ID)" >&2
    docker start --attach "$BUILD_IMAGE_CONTAINER_ID" >&2
    echo "Copying installation files to host" >&2
    docker cp "$BUILD_IMAGE_CONTAINER_ID:/opt/$SYCL" "$PWD/install/opt" >&2

    echo "Building Celerity build container" >&2
    cp -r ../common install >&2
    echo "$VERSION" > install/VERSION
    docker build \
        --build-arg=UBUNTU="$UBUNTU" \
        ${CUDA+"--build-arg=CUDA=$CUDA"} \
        ${INTEL_COMPUTE_RT+"--build-arg=INTEL_COMPUTE_RT=$INTEL_COMPUTE_RT"} \
        ${INTEL_IGC+"--build-arg=INTEL_IGC=$INTEL_IGC"} \
        --tag "$COMMIT_TAG" --tag "$GIT_REF_TAG" install >&2

    echo -e "$COMMIT_TAG\n$GIT_REF_TAG" > "$SYCL_TAGS_FILE"
}

build-sycl-from-distribution() {
    set -eu -o pipefail

    TARBALL="$1"

    # log to a file to avoid choking tar on head -1 and triggering set -e
    tar tf "$TARBALL" > "$TMP_DIR/tarlist"
    PACKAGE_NAME="$(head -1 "$TMP_DIR/tarlist" | cut -d/ -f1)"
    VERSION="Ubuntu ${UBUNTU} ${CUDA+CUDA $CUDA }${INTEL_COMPUTE_RT+Intel Compute Runtime $INTEL_COMPUTE_RT }$SYCL $REF"

    echo "Building $VERSION" >&2

    BASE_TAG="$SYCL:ubuntu$UBUNTU"
    SYMBOLIC_TAG="$BASE_TAG-$(echo -n "$REF" | tr -sc 'A-Za-z0-9.' '-')"

    EXISTING_IMAGE_ID="$(docker images -f "reference=$SYMBOLIC_TAG" -q)"
    if [ -n "$EXISTING_IMAGE_ID" ] && ! [ -n "${FORCE+x}" ]; then
        echo "Image $SYMBOLIC_TAG (aka $EXISTING_IMAGE_ID) already exists" >&2
        echo "$SYMBOLIC_TAG" > "$SYCL_TAGS_FILE"
        exit 0
    fi

    rm -rf install/opt >&2
    mkdir -p install/opt >&2
    cd install/opt
    tar xf "$TARBALL" >&2
    mv "$PACKAGE_NAME" "$SYCL" >&2
    cd ../..

    cp -r ../common install >&2
    echo "$VERSION" > install/VERSION
    docker build \
        --build-arg=UBUNTU="$UBUNTU" \
        ${CUDA+"--build-arg=CUDA=$CUDA"} \
        ${INTEL_COMPUTE_RT+"--build-arg=INTEL_COMPUTE_RT=$INTEL_COMPUTE_RT"} \
        ${INTEL_IGC+"--build-arg=INTEL_IGC=$INTEL_IGC"} \
        --tag "$SYMBOLIC_TAG" install >&2

    echo "$SYMBOLIC_TAG" > "$SYCL_TAGS_FILE"
}

cd "$SYCL_DIR"
case "$SYCL" in
    # run build-sycl-* functions in subshells to make `trap EXIT` work
    hipsycl) (build-sycl-from-source "https://github.com/illuhad/hipSYCL.git");;
    dpcpp) (build-sycl-from-source "https://github.com/intel/llvm.git");;
    computecpp)
        set -- ${REF//-/ }  # split args on -
        DISTRIBUTION="computecpp${2:+"_$2"}-ce"
        VERSION="$1"
        SYSTEM=x86_64-linux-gnu
        (build-sycl-from-distribution "$(pwd)/dist/$DISTRIBUTION-$VERSION-$SYSTEM.tar"*)
        ;;
    *) usage;;
esac

build-project-env() {
    PROJECT="$1"

    readarray -t SYCL_TAGS < "$SYCL_TAGS_FILE"
    declare -a TAG_FLAGS
    for SYCL_TAG in "${SYCL_TAGS[@]}"; do
        TAG_FLAGS+=(--tag "$PROJECT-build/${SYCL_TAG}")
    done

    cp -r common "$PROJECT"-build >&2
    cp "$SYCL/$PROJECT-options.sh" $PROJECT-build
    docker build \
        --build-arg=SYCL_IMAGE="${SYCL_TAGS[0]}" \
        "${TAG_FLAGS[@]}" \
        $PROJECT-build >&2
}

cd "$ROOT_DIR"
build-project-env celerity
if [ "$UBUNTU" == 22.04 ] && [ "$SYCL" == hipsycl ]; then build-project-env ndzip; fi
