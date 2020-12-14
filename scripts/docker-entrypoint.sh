#!/bin/bash
TIMEOUT=120
RUNNER_CMD="$@"

./$RUNNER_CMD

# The GitHub Actions Runner updates itself automatically.
#
# During an auto-update, it will terminate and then auto-restart.
# For this reason, we cannot use the runner directly as the container CMD,
# as it will otherwise cause the container to be restartet whenever it
# does an update (as the container exits once CMD terminates).
#
# As a workaround, we first wait $TIMEOUT seconds to see if the runner
# successfully restarted itself.

while [ true ]; do
	# Try to detect whether the runner is offline for more than $TIMEOUT,
	# and if so, exit (causing Docker to restart the container).
	sleep $TIMEOUT

	if [ ! $(pgrep $RUNNER_CMD) ]; then
		echo "Command '$RUNNER_CMD' not running for $TIMEOUT seconds. Forcing container restart..."
		exit
	fi
done

