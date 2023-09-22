#!/bin/bash

# A script for building EPICS container images.
#
# Note that this is implemented in bash to make it portable between
# CI frameworks. This approach uses the minimum of GitHub Actions.
# Also works locally for testing outside of CI (with podman-docker installed)
#
# INPUTS:
#   PUSH: if true, push the container image to the registry
#   TAG: the tag to use for the container image
#   REGISTRY: the container registry to push to
#   REPOSITORY: the container repository to push to
#   CACHE: the directory to use for caching
#   PLATFORM: the platform to build for (linux/amd64 or linux/arm64)

set -xe

THIS_FOLDER=$(dirname ${0})
# ibek-support is normally a submodule of the Docker Context so we need to
# pass the container context as the folder above the ibek-support folder
CONTEXT=$(realpath ${THIS_FOLDER}/../..)

BASE_VERSION="23.9.2"

ARCH=${ARCH:-linux}
PLATFORM=${PLATFORM:-linux/amd64}
TAG=${TAG:-latest}

# decide on container build tool
if which docker > /dev/null ; then
    docker=docker
else
    echo using podman
    docker=podman
fi

NEWCACHE=${CACHE}-new

# check for podman - it might be aliased to docker so -v gets the real name
if $docker -v | grep podman ; then
    # podman command line parameters (just use local cache)
    cachefrom=""
    cacheto=""
else
    # setup a buildx driver for multi-arch / remote cached builds
    docker buildx create --driver docker-container --use
    # docker command line parameters
    cachefrom=--cache-from=type=local,src=${CACHE}
    cacheto=--cache-to=type=local,dest=${NEWCACHE},mode=max
fi

do_build() {
    TARGET_ARCHITECTURE=$1
    TARGET=$2
    DOCKERFILE=$3
    shift 3

    args="
        --build-arg TARGET_ARCHITECTURE=${TARGET_ARCHITECTURE}
        --build-arg BASE=${BASE_VERSION}
        --build-arg REGISTRY=ghcr.io/epics-containers
        --target ${TARGET}
        --load
        -t test_image_only
        -f ${DOCKERFILE}
    "
    if [[ ${TARGET_ARCHITECTURE} == "linux" ]] ; then
        args="${args} --platform=${PLATFORM}"
    fi

    echo "CONTAINER BUILD FOR ${image_name} with ARCHITECTURE=${TARGET_ARCHITECTURE} ..."

    (
        set -x
        $docker buildx build ${args} ${*} ${CONTEXT}
    )
}


# build the container images for each Dockerfile in tests folder

for dockerfile in ${THIS_FOLDER}/Dockerfile*; do
    # make two targets from each Dockerfile
    do_build ${ARCH} developer ${dockerfile}
    do_build ${ARCH} runtime ${dockerfile}

    # launch the runtime IOC container
    $docker run --name test_me --rm -dit test_image_only

    # verify that the IOC is running - but give it time to start
    for retry in {1..10}; do
        sleep 1
        if $docker exec test_me ps aux | grep /epics/ioc/bin/linux-x86_64/ioc ; then
            echo "IOC is running"
            break
        fi
    done

    # The above check is sufficient to show that the generic IOC will load and
    # run and that all the necessary runtime libraries are in place.
    #
    # for more detailed testing add a Verify.xxx.sh script where xxx is the
    # the same as the suffix on the Dockerfile. See Verify.asyn for an example.
    VERIFY=Verify."${dockerfile#*.}"
    if [[ -f ${THIS_FOLDER}/${VERIFY} ]] ; then
        $THIS_FOLDER/${VERIFY} test_me
    fi

    $docker stop -t0 test_me

    if [[ $retry == 10 ]] ; then
        echo "ERROR: IOC for ${dockerfile} did not start"
        exit 1
    fi
done

