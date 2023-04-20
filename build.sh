#!/usr/bin/env bash
# Use this script to run build related commands in docker environment

# Exit when any command fails
set -e

# Switch to script directory
cd "$(dirname "$0")" || exit

export PROJECT="monitoring-system"

# Create a docker network for the integration tests
if [ -z "$(docker network ls --filter name=^${PROJECT}$ --format="{{ .Name }}")" ] ; then
  docker network create "${PROJECT}" ;
fi

[[ -z "${WORKDIR}" ]] && WORKDIR="${PWD}" || WORKDIR="${WORKDIR}"

# Extract the host IP
export HOST_IP="$(hostname -I | cut -d ' ' -f1)"

# Create the build container image and start the build container (linux)
docker build --target monitoring-system-builder -t monitoring-system-builder . && \
docker run --user root -it --rm --net="${PROJECT}" --name "${PROJECT}-builder" \
  -e PROJECT \
  -e HOST_PWD="${WORKDIR}" \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "${WORKDIR}":/src \
  -v /tmp:/tmp \
  monitoring-system-builder "$@"