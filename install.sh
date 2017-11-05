#!/bin/sh

set -eu

check_docker_access() {

    # Extract socket path
    DOCKER_SOCK_FILE=""
    if [ -z "${DOCKER_HOST+x}" ]; then
        DOCKER_SOCK_FILE="/var/run/docker.sock"
    else
        WITHOUT_PREFIX="${DOCKER_HOST#unix://}"
        if [ "$WITHOUT_PREFIX" != "$DOCKER_HOST" ]; then
            DOCKER_SOCK_FILE="$WITHOUT_PREFIX"
        fi
    fi

    # shellcheck disable=SC2166
    if [ \( -n "$DOCKER_SOCK_FILE" \) -a \( ! -w "$DOCKER_SOCK_FILE" \) ]; then
        echo "ERROR: cannot write to docker socket: $DOCKER_SOCK_FILE" >&2
        echo "change socket permissions or try using sudo" >&2
        exit 1
    fi
}

MIN_DOCKER_VERSION=17.06.2

check_docker_version() {
    if ! DOCKER_VERSION=$(docker -v | sed -n 's%^Docker version \([0-9]\{1,\}\.[0-9]\{1,\}\.[0-9]\{1,\}\).*$%\1%p') \
        || [ -z "$DOCKER_VERSION" ]; then
        echo "ERROR: Unable to parse docker version" >&2
        exit 1
    fi

    DOCKER_VERSION_MAJOR=$(echo "$DOCKER_VERSION" | cut -d. -f 1)
    DOCKER_VERSION_MINOR=$(echo "$DOCKER_VERSION" | cut -d. -f 2)
    DOCKER_VERSION_PATCH=$(echo "$DOCKER_VERSION" | cut -d. -f 3)

    MIN_DOCKER_VERSION_MAJOR=$(echo "$MIN_DOCKER_VERSION" | cut -d. -f 1)
    MIN_DOCKER_VERSION_MINOR=$(echo "$MIN_DOCKER_VERSION" | cut -d. -f 2)
    MIN_DOCKER_VERSION_PATCH=$(echo "$MIN_DOCKER_VERSION" | cut -d. -f 3)

    # shellcheck disable=SC2166
    if [ \( "$DOCKER_VERSION_MAJOR" -lt "$MIN_DOCKER_VERSION_MAJOR" \) -o \
        \( "$DOCKER_VERSION_MAJOR" -eq "$MIN_DOCKER_VERSION_MAJOR" -a \
        \( "$DOCKER_VERSION_MINOR" -lt "$MIN_DOCKER_VERSION_MINOR" -o \
        \( "$DOCKER_VERSION_MINOR" -eq "$MIN_DOCKER_VERSION_MINOR" -a \
        \( "$DOCKER_VERSION_PATCH" -lt "$MIN_DOCKER_VERSION_PATCH" \) \) \) \) ]; then
        echo "ERROR: required Docker version $MIN_DOCKER_VERSION or later; you are running $DOCKER_VERSION" >&2
        exit 1
    fi
}

check_docker_access
check_docker_version

usage_and_die() {
    echo "Usage: install TOKEN"
    exit 1
}

[ $# -gt 0 ] || usage_and_die
WEAVE_TOKEN=$1
shift 1

check_docker_swarm() {
    if ! DOCKER_SWARM_MODE=$(docker info | grep 'Swarm: active') \
        || [ -z "DOCKER_SWARM_MODE" ]; then
        echo "Docker Swarm mode is not active, installing Weave Scope"
        scope launch --service-token=${WEAVE_TOKEN}
        exit 0
    fi
}

check_docker_swarm

TOKEN=${WEAVE_TOKEN} docker stack deploy -c docker-compose.yml weave

