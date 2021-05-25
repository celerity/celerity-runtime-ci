#!/bin/bash
set -o errexit -o pipefail -o noclobber -o nounset

function usage {
	echo "Usage: $0 <name> --intel|nvidia [--enable-hipsycl] [--enable-computecpp]" 2>&1
	echo -e "\t<name> will be the name of the GitHub actions runner, as displayed in the GitHub UI (for example \"gpuc1\")."
}

if [[ $# -le 1 ]]; then
	usage
	exit 1
fi

! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
	echo "This script requires the enhanced version of getopt." 2>&1
	exit 1
fi

if [[ ! -f token.txt ]]; then
	echo "Please create file 'token.txt' containing the GitHub runner secret token."
	exit 1
fi

LONGOPTIONS="intel,nvidia,enable-hipsycl,enable-computecpp"

! ARGS=$(getopt --options="" --longoptions="$LONGOPTIONS" --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
	exit 1
fi
eval set -- "$ARGS"

PLATFORM=""
ENABLED_IMPLS=()

function set_platform() {
	if [[ $PLATFORM != "" ]]; then
		echo "Platform can be either --intel or --nvidia, not both" 2>&1
		exit 1
	fi
	PLATFORM="$1"
}

while true; do
	case "$1" in
		--intel)
			set_platform "intel"
			shift
			;;
		--nvidia)
			set_platform "nvidia"
			shift
			;;
		--enable-hipsycl)
			ENABLED_IMPLS+=("hipSYCL")
			shift
			;;
		--enable-computecpp)
			ENABLED_IMPLS+=("ComputeCpp")
			shift
			;;
		--)
			shift
			break
			;;
		*)
			echo "Unexpected argument" 2>&1
			exit 1
			;;
	esac
done

if [[ $# -ne 1 ]]; then
	usage
	exit 1
fi

RUNNER_NAME="$1"
echo "Setting GitHub actions runner name to \"$RUNNER_NAME\"."
RUNNER_LABELS="$PLATFORM"
echo "Setting GitHub actions runner labels to \"$RUNNER_LABELS\"."

if [[ ${#ENABLED_IMPLS[@]} == 0 ]]; then
	echo "Please enable at least one SYCL implementation." 2>&1
	exit 1
fi

RENDER_GID=999
if [[ "$PLATFORM" == "intel" ]]; then
	! RENDER_GID=$(getent group render | cut -d: -f3)
	if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
		echo "Failed to obtain ID of \"render\" group." 2>&1
		exit 1
	fi
	echo "ID of \"render\" group is $RENDER_GID."
fi

# We pass a JSON array of enabled implementations into the container,
# which is then parsed by the GitHub workflow file.
FS=$'\n' ENABLED_IMPLS=($(sort <<<"${ENABLED_IMPLS[*]}")); unset IFS
SYCL_IMPLS_JSON=$(printf ",\"%s\"" "${ENABLED_IMPLS[@]}")
SYCL_IMPLS_JSON="[${SYCL_IMPLS_JSON:1}]"

HIPSYCL_BASE_IMAGE="tools"
COMPUTECPP_BASE_IMAGE="tools"
ACTIONS_RUNNER_BASE_IMAGE="tools"

if [[ ${ENABLED_IMPLS[@]} =~ "hipSYCL" ]]; then
	echo "Enabling support for hipSYCL."
	HIPSYCL_BASE_IMAGE="tools"
	ACTIONS_RUNNER_BASE_IMAGE="hipsycl"
fi

if [[ ${ENABLED_IMPLS[@]} =~ "ComputeCpp" ]]; then
	echo "Enabling support for ComputeCpp."
	if [[ ! -d computecpp || ! -d computecpp/bin ]]; then
		echo "Please create folder 'computecpp' containing files extracted from ComputeCpp tarball."
		exit 1
	fi
	if [[ ${ENABLED_IMPLS[@]} =~ "hipSYCL" ]]; then
		COMPUTECPP_BASE_IMAGE="hipsycl"
	else
		COMPUTECPP_BASE_IMAGE="tools"
	fi
	ACTIONS_RUNNER_BASE_IMAGE="computecpp"
fi

set -x
DOCKER_BUILDKIT=1 docker build . \
	--build-arg VENDOR_BASE_IMAGE="$PLATFORM" \
	--build-arg RENDER_GID="$RENDER_GID" \
	--build-arg HIPSYCL_BASE_IMAGE="$HIPSYCL_BASE_IMAGE" \
	--build-arg COMPUTECPP_BASE_IMAGE="$COMPUTECPP_BASE_IMAGE" \
	--build-arg ACTIONS_RUNNER_BASE_IMAGE="$ACTIONS_RUNNER_BASE_IMAGE" \
	--build-arg RUNNER_NAME="${RUNNER_NAME}" \
	--build-arg RUNNER_LABELS="${RUNNER_LABELS}" \
	--build-arg SYCL_IMPLS_JSON="$SYCL_IMPLS_JSON" \
	--secret id=token,src=token.txt \
	--tag celerity-ci-runner:latest

