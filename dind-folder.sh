#!/bin/bash
set -euo pipefail

DINDFOLDER=${0##*/}
IMAGE="debian:jessie"

usage()
{
    cat << USAGE >&2
Usage:
    $DINDFOLDER DIR
        DIR   Source directory to be transported to the host

    As a result:
    - A new directory TMPDIR was created on the docker host in a new random temporary directory under /tmp
    - The local DIR was copied within TMPDIR
    - You will get the target path of the host in STDOUT as "TMPDIR/DIR"

    This script uses the well-knwn docker socket hack
USAGE
    exit 1
}

# Check parameter
if [ $# -eq 0 ]; then
    usage
fi

# First check if we are running within a docker container
if [ ! -f /.dockerenv ] ; then
    echo "ERROR: Not running within docker"
    exit 1
fi

# We are within docker container: check if we have /var/run/docker.sock
docker info > /dev/null 2>&1
if [ $? -ne 0 ] ; then
    echo "ERROR: Don't have /var/run/docker.sock"
    exit 1
fi

SOURCE=$1

# Configuration
TMPDIR=$(mktemp -d -u)
BASEDIR=$(basename "${SOURCE}")

# Prepare container (and also the host)
ID=$(docker create --privileged -v /var/run/docker.sock:/var/run/docker.sock -v "${TMPDIR}:/mnt/dind-folder" ${IMAGE})
docker cp "${SOURCE}" ${ID}:/mnt/dind-folder/

# Prepare things in local
echo $TMPDIR