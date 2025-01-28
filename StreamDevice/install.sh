#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=StreamDevice
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe


if [[ $EPICS_TARGET_ARCH == "RTEMS"* ]]; then

    PCRE=7.5
    cd ${SUPPORT}/${NAME}
    curl -LO https://sourceforge.net/projects/pcre/files/pcre/${PCRE}/pcre-${PCRE}.tar.gz
    tar -xzf pcre-${PCRE}.tar.gz
    cd pcre-${PCRE}

    # set up cross-compilation
    export CC=powerpc-rtems6-gcc
    export CXX=powerpc-rtems6-g++
    ./configure --host=powerpc-rtems6 --build=x86_64-linux-gnu \
        --prefix=${SUPPORT}/${NAME}/pcre-install
    make

    # declare location of the pcre system library
    ibek support add-config-macro ${NAME} PCRE_LIB ${SUPPORT}/${NAME}/pcre-install/lib
    ibek support add-config-macro ${NAME} PCRE_INCLUDE ${SUPPORT}/${NAME}/pcre-install/include
else
    # prce developer library
    ibek support apt-install libpcre3-dev

    # declare location of the pcre system library
    ibek support add-config-macro ${NAME} PCRE_LIB /usr/lib/x86_64-linux-gnu
fi

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/paulscherrerinstitute/
ibek support register ${NAME}

# set CALC blank (to overwrite the RELEASE value) to build without calc
ibek support add-release-macro CALC --no-replace

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs stream
ibek support add-dbds stream-base.dbd stream.dbd


# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}
