#!/bin/bash

set -eu -o pipefail

REPO="$1"
TAG="$2"
shift 2

curl -SsfL -H "Accept: application/vnd.github+json" "https://api.github.com/repos/$REPO/releases/tags/$TAG" \
        | python3 -c "import sys, json; print(json.load(sys.stdin)['assets_url'])" \
        | xargs curl -SsfL -H "Accept: application/vnd.github+json" \
        | python3 "$(dirname "$0")/list-download-urls.py" "$@" \
        | xargs curl -SsfL --remote-name-all
