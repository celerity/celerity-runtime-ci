#!/bin/bash

set -eu -o pipefail

usage() {
    echo "Usage: $0 [-f|--force] hipsycl|dpcpp[:]<git-ref>" >&2
    echo "       $0 [-f|--force] computecpp[:]<version>" >&2
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

if [ $# -eq 1 ]; then set -- ${1//:/ }; fi  # split args on :
if [ $# -ne 2 ]; then usage; fi
LIBRARY="$1"
REF="$2"

LIB_DIR="$(readlink -f "$(dirname "$0")")/$LIBRARY"
cd "$LIB_DIR"

build-from-source() {
    GIT_REMOTE="$1"

    rm -rf install/opt
    mkdir -p install/opt

    SRC_BASE_DIR="$HOME/celerity-src"
    mkdir -p "$SRC_BASE_DIR"
    SRC_DIR="$SRC_BASE_DIR/$LIBRARY"
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
    git submodule update --init --recursive
    VERSION="$(git log --format=format:"$LIBRARY $REF @ %H | %ci" -1)"

    cd "$LIB_DIR"
    echo "Building $VERSION"

    BUILD_IMAGE_NAME="build/$LIBRARY"
    IMAGE_NAME="build/celerity/$LIBRARY"
    COMMIT_TAG="$IMAGE_NAME:$COMMIT_ID"
    GIT_REF_TAG="$IMAGE_NAME:$(echo -n "$REF" | tr -sc 'A-Za-z0-9.' '-')"

    EXISTING_IMAGE_ID="$(docker images -f "reference=$COMMIT_TAG" -q)"
    if [ -n "$EXISTING_IMAGE_ID" ] && ! [ -n "${FORCE+x}" ]; then
        docker tag "$COMMIT_TAG" "$GIT_REF_TAG"
        echo "Image $GIT_REF_TAG (aka $EXISTING_IMAGE_ID) already exists" >&2
        exit 0
    fi

    # We use a named volume for ccache.
    # The volume is managed by Docker and persists between containers.
    CCACHE_VOLUME="ccache-$LIBRARY"

    echo "Creating SYCL build container ($BUILD_IMAGE_NAME:latest)"
    cp -r ../common build
    docker build build --tag "$BUILD_IMAGE_NAME:latest"
    BUILD_IMAGE_CONTAINER_ID=$(docker create \
        --mount "type=bind,src=$SRC_DIR,dst=/src,ro=true" \
        --mount "type=volume,src=$CCACHE_VOLUME,dst=/ccache" \
        "$BUILD_IMAGE_NAME:latest"
    )

    function cleanup {
        echo "Removing SYCL build container ($BUILD_IMAGE_CONTAINER_ID)"
        docker rm "$BUILD_IMAGE_CONTAINER_ID"
    }
    trap cleanup EXIT

    echo "Starting SYCL build container ($BUILD_IMAGE_CONTAINER_ID)"
    docker start --attach "$BUILD_IMAGE_CONTAINER_ID"
    echo "Copying installation files to host"
    docker cp "$BUILD_IMAGE_CONTAINER_ID:/opt/$LIBRARY" "$PWD/install/opt"

    echo "Building Celerity build container"
    cp -r ../common install
    echo "$VERSION" > install/VERSION
    docker build --tag "$COMMIT_TAG" --tag "$GIT_REF_TAG" install
}

build-from-distribution() {
    TARBALL="$1"

    # log to a file to avoid choking tar on head -1 and triggering set -e
    tar tf "$TARBALL" > /tmp/tarlist
    PACKAGE_NAME="$(head -1 /tmp/tarlist | cut -d/ -f1)"
    VERSION="$LIBRARY $REF"

    echo "Building $VERSION"

    IMAGE_NAME="build/celerity/$LIBRARY"
    SYMBOLIC_TAG="$IMAGE_NAME:$(echo -n "$REF" | tr -sc 'A-Za-z0-9.' '-')"

    EXISTING_IMAGE_ID="$(docker images -f "reference=$SYMBOLIC_TAG" -q)"
    if [ -n "$EXISTING_IMAGE_ID" ] && ! [ -n "${FORCE+x}" ]; then
        echo "Image $SYMBOLIC_TAG (aka $EXISTING_IMAGE_ID) already exists" >&2
        exit 0
    fi

    rm -rf install/opt
    mkdir -p install/opt
    cd install/opt
    tar xf "$TARBALL"
    mv "$PACKAGE_NAME" "$LIBRARY"
    cd ../..

    cp -r ../common install
    echo "$VERSION" > install/VERSION
    docker build --tag "$SYMBOLIC_TAG" install
}

case "$LIBRARY" in
    hipsycl) build-from-source "https://github.com/illuhad/hipSYCL.git";;
    dpcpp) build-from-source "https://github.com/intel/llvm.git";;
    computecpp) build-from-distribution "$(pwd)/dist/computecpp-ce-$REF-x86_64-linux-gnu.tar.gz";;
    *) usage;;
esac

