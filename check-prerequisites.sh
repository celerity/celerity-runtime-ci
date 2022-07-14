#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

! DOCKER_EXE=$(which docker)
if [ -z "$DOCKER_EXE" ] || [ ! -x "$DOCKER_EXE" ]; then
    echo "Cannot find docker executable" 2>&1
    exit 1
fi

if [ ! $(docker info 2> /dev/null | grep rootless) ]; then
    echo "Docker must be running rootless for security reasons" 2>&1
    exit 1
fi

! SHIM_CHECK=$(CELERITY_DOCKER_SHIM_CHECK=1 docker ps 2>&1 1>/dev/null)
if [ "$SHIM_CHECK" != "Docker shimmed" ]; then
    echo "Docker is not correctly shimmed for Celerity CI" 2>&1
    exit 1
fi

if ! grep -qF "docker-prune.sh" <<< "$(crontab -l)"; then
    echo "Warning: Crontab for Docker pruning not found" 2>&1
fi
