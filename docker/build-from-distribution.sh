#!/bin/sh

set -e

usage() {
    echo "Usage: $0 [-f|--force] computecpp <version>" >&2
    exit 1
}

ARGS=$(getopt --options="f" --longoptions="force" --name "$0" -- "$@") || usage
eval set -- "$ARGS"

unset FORCE
while true; do
    case "$1" in
        -f | --force) FORCE=1; shift;;
        --) shift; break;;
    esac
done

if [ $# -ne 2 ]; then usage; fi
LIBRARY="$1"
SYMBOLIC_REF="$2"
if [ "$LIBRARY" != computecpp ]; then usage; fi

cd "$(dirname "$0")/$LIBRARY"
TARBALL="$(pwd)/dist/computecpp-ce-$SYMBOLIC_REF-x86_64-linux-gnu.tar.gz"
PACKAGE_NAME="$(tar tf "$TARBALL" | head -1 | cut -d/ -f1)"
VERSION="$LIBRARY $SYMBOLIC_REF"

echo "Building $VERSION"

IMAGE_NAME="build/celerity/$LIBRARY"
SYMBOLIC_TAG="$IMAGE_NAME:$(echo -n "$SYMBOLIC_REF" | tr -sc 'A-Za-z0-9.' '-')"

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

echo "$VERSION" > install/VERSION
docker build install --tag "$SYMBOLIC_TAG"

