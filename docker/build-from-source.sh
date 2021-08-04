#!/bin/sh

set -e

usage() {
    echo "Usage: $0 [-f|--force] hipsycl|dpc++ <git-ref>" >&2
    exit 1
}

ARGS=$(getopt --options="f" --longoptions="force" --name "$0" -- "$@") || usage
eval set -- "$ARGS"

unset FORCE
while true; do
    case "$1" in
        -f | --force) FORCE=yes; shift;;
        --) shift; break;;
    esac
done

if [ $# -ne 2 ]; then usage; fi
LIBRARY="$1"
GIT_REF="$2"

case "$LIBRARY" in
    hipsycl) GIT_REMOTE="https://github.com/illuhad/hipSYCL.git";;
    dpc++) GIT_REMOTE="https://github.com/intel/llvm.git";;
    *) usage;;
esac

cd "$(dirname "$0")/$LIBRARY"
mkdir -p install/opt ccache

if [ -e src ]; then
    cd src
    git fetch origin
else
    git clone "$GIT_REMOTE" src
    cd src
fi

COMMIT_ID=$(git rev-parse "remotes/origin/$GIT_REF" 2>/dev/null) \
    || COMMIT_ID=$(git rev-parse "tags/$GIT_REF" 2>/dev/null) \
    || COMMIT_ID=$(grep '^[0-9a-f]\+$' <<< "$GIT_REF") \
    || (echo "Error: cannot resolve Git ref $GIT_REF" >&2; exit 1)

git -c advice.detachedHead=false checkout --force "$COMMIT_ID"
git submodule update --init --recursive
VERSION="$(git log --format=format:"$LIBRARY $GIT_REF @ %H | %ci" -1)"

cd ..

echo "Building $VERSION"

BUILD_IMAGE_NAME="build/$(echo -n "$LIBRARY" | tr '+' 'p')"
IMAGE_NAME="build/celerity/$(echo -n "$LIBRARY" | tr '+' 'p')"
COMMIT_TAG="$IMAGE_NAME:$COMMIT_ID"
GIT_REF_TAG="$IMAGE_NAME:$(echo -n "$GIT_REF" | tr -sc 'A-Za-z0-9.' '-')"

EXISTING_IMAGE_ID="$(docker images -f "reference=$COMMIT_TAG" -q)"
if [ -n "$EXISTING_IMAGE_ID" ] && ! [ -n "${FORCE+x}" ]; then
    docker tag "$COMMIT_TAG" "$GIT_REF_TAG"
    echo "Image $GIT_REF_TAG (aka $EXISTING_IMAGE_ID) already exists" >&2
    exit 0
fi

docker build build --tag "$BUILD_IMAGE_NAME:latest"
docker run \
    --mount "type=bind,src=$(pwd)/src,dst=/src,ro=true" \
    --mount "type=bind,src=$(pwd)/ccache,dst=/ccache" \
    --mount "type=bind,src=$(pwd)/install/opt,dst=/opt" \
    "$BUILD_IMAGE_NAME:latest"
echo "$VERSION" > install/VERSION
docker build install --tag "$COMMIT_TAG" --tag "$GIT_REF_TAG"

