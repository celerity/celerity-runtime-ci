#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

#
# Prunes dangling and old (> 1 month) Docker images and other unused data.
#

# Delete old images (will not delete images that are still used by existing containers or child images)
! docker images 2>&1 | \
    awk -F '[[:space:]][[:space:]]+' '$4 ~ /[5-9] weeks ago/ || $4 ~ /[1-9] months ago/ {print $3}' | \
    xargs docker rmi

# Prune dangling images
! docker image prune <<< "y"

# Prune other unused system data
! docker system prune <<< "y"

