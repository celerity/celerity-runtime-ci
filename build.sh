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

unset CUDA
if [ "$SYCL" == hipsycl ]; then
	if [ "$UBUNTU" == 20.04 ]; then
		CUDA=11.0.3
	elif [ "$UBUNTU" == 22.04 ]; then
		CUDA=11.7.0
	else
		echo "I don't know which CUDA version to select for Ubuntu $UBUNTU"
	fi 
fi

LIB_DIR="$(readlink -f "$(dirname "$0")")/$SYCL"
cd "$LIB_DIR"

build-from-source() {
    GIT_REMOTE="$1"

    rm -rf install/opt
    mkdir -p install/opt

    SRC_BASE_DIR="$HOME/celerity-src"
    mkdir -p "$SRC_BASE_DIR"
    SRC_DIR="$SRC_BASE_DIR/$SYCL"
    if [ -e "$SRC_DIR" ]; then
        cd "$SRC_DIR"
        git fetch --all
    else
        git clone "$GIT_REMOTE" "$SRC_DIR"
        cd "$SRC_DIR"
    fi

    COMMIT_ID=$(git rev-parse "remotes/origin/$REF" 2>/dev/null) \
        || COMMIT_ID=$(git rev-parse "tags/$REF" 2>/dev/null) \
        || COMMIT_ID=$(grep '^[0-9a-f]\+$' <<< "$REF") \
        || (echo "Error: cannot resolve Git ref $REF" >&2; exit 1)

    git -c advice.detachedHead=false checkout --force "$COMMIT_ID"
    git clean -fdx
    git submodule update --init --recursive
    VERSION="Ubuntu ${UBUNTU} ${CUDA+CUDA: $CUDA }$SYCL $REF @ $(git log --format=format:"%H | %ci" -1)"

    cd "$LIB_DIR"
    echo "Building $VERSION"

    BUILD_IMAGE_TAG="build/$SYCL:ubuntu$UBUNTU"
    IMAGE_NAME="build/celerity/$SYCL"
	BASE_TAG="$IMAGE_NAME:ubuntu$UBUNTU"
    COMMIT_TAG="$BASE_TAG-$COMMIT_ID"
    GIT_REF_TAG="$BASE_TAG-$(echo -n "$REF" | tr -sc 'A-Za-z0-9.' '-')"

    EXISTING_IMAGE_ID="$(docker images -f "reference=$COMMIT_TAG" -q)"
    if [ -n "$EXISTING_IMAGE_ID" ] && ! [ -n "${FORCE+x}" ]; then
        docker tag "$COMMIT_TAG" "$GIT_REF_TAG"
        echo "Image $GIT_REF_TAG (aka $EXISTING_IMAGE_ID) already exists" >&2
        exit 0
    fi

    # We use a named volume for ccache.
    # The volume is managed by Docker and persists between containers.
    CCACHE_VOLUME="ccache-$SYCL"

    echo "Creating SYCL build container ($BUILD_IMAGE_TAG)"
    cp -r ../common build
    docker build build \
		--build-arg=UBUNTU="$UBUNTU" ${CUDA+"--build-arg=CUDA=$CUDA"} \
		--tag "$BUILD_IMAGE_TAG"
    BUILD_IMAGE_CONTAINER_ID=$(docker create \
        --mount "type=bind,src=$SRC_DIR,dst=/src" \
        --mount "type=volume,src=$CCACHE_VOLUME,dst=/ccache" \
        "$BUILD_IMAGE_TAG"
    )

    function cleanup {
        echo "Removing SYCL build container ($BUILD_IMAGE_CONTAINER_ID)"
        docker rm "$BUILD_IMAGE_CONTAINER_ID"
    }
    trap cleanup EXIT

    echo "Starting SYCL build container ($BUILD_IMAGE_CONTAINER_ID)"
    docker start --attach "$BUILD_IMAGE_CONTAINER_ID"
    echo "Copying installation files to host"
    docker cp "$BUILD_IMAGE_CONTAINER_ID:/opt/$SYCL" "$PWD/install/opt"

    echo "Building Celerity build container"
    cp -r ../common install
    echo "$VERSION" > install/VERSION
    docker build \
		--build-arg=UBUNTU="$UBUNTU" ${CUDA+"--build-arg=CUDA=$CUDA"} \
		--tag "$COMMIT_TAG" --tag "$GIT_REF_TAG" install
}

build-from-distribution() {
    TARBALL="$1"

    # log to a file to avoid choking tar on head -1 and triggering set -e
    tar tf "$TARBALL" > /tmp/tarlist
    PACKAGE_NAME="$(head -1 /tmp/tarlist | cut -d/ -f1)"
    VERSION="Ubuntu ${UBUNTU} ${CUDA+CUDA: $CUDA }$SYCL $REF"

    echo "Building $VERSION"

    IMAGE_NAME="build/celerity/$SYCL"
	BASE_TAG="$IMAGE_NAME:ubuntu$UBUNTU"
    SYMBOLIC_TAG="$BASE_TAG-$(echo -n "$REF" | tr -sc 'A-Za-z0-9.' '-')"

    EXISTING_IMAGE_ID="$(docker images -f "reference=$SYMBOLIC_TAG" -q)"
    if [ -n "$EXISTING_IMAGE_ID" ] && ! [ -n "${FORCE+x}" ]; then
        echo "Image $SYMBOLIC_TAG (aka $EXISTING_IMAGE_ID) already exists" >&2
        exit 0
    fi

    rm -rf install/opt
    mkdir -p install/opt
    cd install/opt
    tar xf "$TARBALL"
    mv "$PACKAGE_NAME" "$SYCL"
    cd ../..

    cp -r ../common install
    echo "$VERSION" > install/VERSION
    docker build \
		--build-arg=UBUNTU="$UBUNTU" ${CUDA+"--build-arg=CUDA=$CUDA"} \
		--tag "$SYMBOLIC_TAG" install
}

case "$SYCL" in
	hipsycl) build-from-source "https://github.com/illuhad/hipSYCL.git";;
    dpcpp) build-from-source "https://github.com/intel/llvm.git";;
    computecpp)
        set -- ${REF//-/ }  # split args on -
        DISTRIBUTION="computecpp${2:+"_$2"}-ce"
        VERSION="$1"
        SYSTEM=x86_64-linux-gnu
        build-from-distribution "$(pwd)/dist/$DISTRIBUTION-$VERSION-$SYSTEM.tar"*
        ;;

    *) usage;;
esac

