#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

usage() {
    NAME=$(basename "$0")
    echo "Usage: $NAME <install|uninstall>" >&2
    exit 1
}

[[ $# == 1 ]] || usage
CMD=$1
[[ $CMD != "install" && $CMD != "uninstall" ]] && usage

SCRIPT_DIR=$(dirname "$(readlink -fn "$0")")
SCRIPT="docker-prune.sh"
INSTALL_DIR="$HOME/.local/bin"
INSTALLED_SCRIPT="$INSTALL_DIR/$SCRIPT"
! CRONTAB=$(crontab -l 2>/dev/null)
! EXISTS=$(grep -F "$INSTALLED_SCRIPT" <<< "$CRONTAB")

if [[ $CMD == "install" ]]; then
    if [[ -n "$EXISTS" ]]; then
        echo "Script already in crontab, skipping: $EXISTS" >&2
        exit 1
    fi

    DOCKER_EXE=$(which docker)
    if [[ ! -x "$DOCKER_EXE" ]]; then
        echo "Unable to find docker executable" >&2
        exit 1
    fi

    if [[ -f "$INSTALLED_SCRIPT" ]]; then
        echo "Script at $INSTALLED_SCRIPT already exists. Run uninstall first."
        exit 1
    fi

    echo "Installing prune script to $INSTALL_DIR with docker executable set to $DOCKER_EXE"
    mkdir -p "$INSTALL_DIR"
    sed "s|%DOCKER%|$DOCKER_EXE|g" "$SCRIPT_DIR/$SCRIPT.template" > "$INSTALLED_SCRIPT"
    chmod u+x "$INSTALLED_SCRIPT"

    # Run once per day at 4:00
    ENTRY="0 4 * * * \"$INSTALLED_SCRIPT\""
    echo "Adding new entry to user crontab: $ENTRY"
    if [[ -n "$CRONTAB" ]]; then
        echo -e "${CRONTAB}\n${ENTRY}" | crontab -
    else
        echo -e "${ENTRY}" | crontab -
    fi
else
    if [[ -f "$INSTALL_DIR/$SCRIPT" ]]; then
        echo "Deleting prune script at $INSTALL_DIR/$SCRIPT"
        rm -f "$INSTALL_DIR/$SCRIPT"
    fi

    if [[ -z $EXISTS ]]; then
        echo "Script not in crontab, skipping." >&2
        exit 1
    fi

    echo "Removing entry from user crontab: $EXISTS"
    ! grep -vF "$EXISTS" <<< "$(crontab -l)" | crontab -
fi