#!/bin/bash
set -e

if [[ ! -f token.txt ]]; then
	echo "Please create file 'token.txt' containing the GitHub runner secret token"
	exit 1
fi

if [[ ! -d computecpp || ! -d computecpp/bin ]]; then
	echo "Please create folder 'computecpp' containing files extracted from ComputeCpp tarball"
	exit 1
fi

set -x
DOCKER_BUILDKIT=1 docker build . \
	--secret id=token,src=token.txt \
	--tag celerity-ci-runner:latest

