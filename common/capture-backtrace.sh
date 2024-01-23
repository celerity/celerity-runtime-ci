#!/bin/bash

# This script requires the host system (outside Docker) to be configured to generate accessible core dumps.
#   1. Set a compatible core pattern in /etc/sysctl.d/10-core-pattern.conf. It must contain no format specifiers
#      other than %p (PID), %f (executable file name, Linux >= 5.9), and %% (% character):
#           fs.suid_dumpable = 1
#           kernel.core_pattern = core.%p
#   2. Set the core file size limit to 0/unlimited (this script will bump ulimit before invoking the user command).
#      The active limits depend on the system and can be found in /proc/1/limits. With systemd, they can be changed
#      globally from /etc/systemd/system.conf:
#           DefaultLimitCORE=0:infinity
#   3. Reboot the host if you had to change /etc/systemd/system.conf, otherwise it is enough to run
#           sysctl -p /etc/sysctl.d/*.conf

set -eu -o pipefail

if [ $# -lt 1 ] || [ "$1" == '--help' ]; then
    echo "Usage: $0 <command> [<arg>...]" >&2
    exit 1
fi

CORE_PATTERN="$(</proc/sys/kernel/core_pattern)"
if [[ "$CORE_PATTERN" =~ %[^pf%] ]]; then
    echo "capture-backtrace: warning: kernel.core_pattern = "$CORE_PATTERN", but capture-backtrace" \
        "only supports the %p, %f and %% specifiers. Please reconfigure the host accordingly." >&2
fi
if [[ ! "$CORE_PATTERN" =~ %p && "$(</proc/sys/kernel/core_uses_pid)" != 0 ]]; then
    CORE_PATTERN+=".%p"
fi

CORE_LIMIT_BEFORE=$(ulimit -c)
ulimit -c unlimited
export LD_PRELOAD="${CI_LD_PRELOAD-}"

"$@" &  # needs to execute in the background, otherwise we cannot query $!
PID=$!

set +e
wait $PID
STATUS=$?

set -e
unset LD_PRELOAD
ulimit -c $CORE_LIMIT_BEFORE

if [ $STATUS -lt 128 ]; then
    exit $STATUS
fi

SIGNAL=$(($STATUS - 128))
echo "capture-backtrace: process $PID exited with signal $SIGNAL" >&2

EXE_NAME="${1##*/}"
# We treat %e as %f, but it's unstable because it can be changed during runtime
CORE_FILE="$(perl -pe "s/(?<!%)%p/$PID/g;s/(?<!%)%[ef]/$EXE_NAME/g;s/%%/%/g" <<< "$CORE_PATTERN")"
if ! [ -f "$CORE_FILE" ]; then
    echo "capture-backtrace: expected core file at $CORE_FILE, but it could not be found." >&2
    exit $STATUS
fi

FILTER_SCRIPT='
    s/warning: [^\n]*\n//g;
    s/(?<=Python Exception)[^\n]*\n//g;
    s/^(?=[^#].*=)/    /;
    print unless /^\[New LWP|^[^#].*\bCatch::|^[^#].*Python Exception/
'

echo "capture-backtrace: found core file at $CORE_FILE" >&2
gdb -q "$1" "$CORE_FILE" -ex "thread apply all frame apply all info locals -q" -ex "q" \
    | perl -ne "$FILTER_SCRIPT" | tee "$EXE_NAME.$PID.trace" >&2
rm -f "$CORE_FILE"
exit $STATUS
