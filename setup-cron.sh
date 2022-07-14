#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

usage() {
    NAME=$(basename "$0")
    echo "Usage: $NAME <install|uninstall>"
    exit 1
}

[[ $# == 1 ]] || usage
CMD=$1
[[ $CMD != "install" && $CMD != "uninstall" ]] && usage

SCRIPT_DIR=$(dirname "$(readlink -fn "$0")")
PRUNE_SCRIPT="$SCRIPT_DIR/docker-prune.sh"
! CRONTAB=$(crontab -l 2>&1)
! EXISTS=$(grep -F "$PRUNE_SCRIPT" <<< "$CRONTAB")

if [[ $CMD == "install" ]]; then
    if [[ -n $EXISTS ]]; then
        echo "Script already in crontab, skipping: $EXISTS"
        exit 1
    fi

    # Run once per day at 4:00
    ENTRY="0 4 * * * \"$PRUNE_SCRIPT\""
    echo "Adding new entry to user crontab: $ENTRY"
    echo -e "${CRONTAB}\n${ENTRY}" | crontab -
else
    if [[ -z $EXISTS ]]; then
        echo "Script not in crontab, skipping."
        exit 1
    fi

    echo "Removing entry from user crontab: $EXISTS"
    grep -vF "$EXISTS" <<< "$(crontab -l)" | crontab -
fi

