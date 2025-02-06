#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=StreamDevice
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/paulscherrerinstitute/
ibek support register ${NAME}

if [[ $EPICS_TARGET_ARCH == "RTEMS"* ]]; then

    ibek support add-libs pcre

    cd ${SUPPORT}/${NAME}

    # get the pcre source
    PCRE=8.45
    zip=https://sourceforge.net/projects/pcre/files/pcre/${PCRE}/pcre-${PCRE}.tar.gz
    if [[ ! -d pcre-${PCRE} ]]; then
        curl -LO ${zip}
        tar -xzf pcre-${PCRE}.tar.gz
    fi
    cd pcre-${PCRE}

    # set up cross-compilation
    export CC=powerpc-rtems6-gcc
    export CXX=powerpc-rtems6-g++
    ./configure --host=powerpc-rtems6 --build=x86_64-linux-gnu \
        --prefix=${SUPPORT}/PCRE
    # remove build of executables - just build the library
    sed -i -E 's/(^[^#].*PROGRAMS =.*$)/# \1/' Makefile
    make
    make install
    make clean

    # fix Makefile to not make StreamApp - we only need the library from src
    # streamApp fails to build for RTEMS as it is a HOST+IOC targetted Makefile
    sed -i -E 's/(^[^#].*streamApp.*$)/# \1/' ${SUPPORT}/${NAME}/Makefile

    # declare location of the pcre library
    ibek support add-config-macro ${NAME} PCRE_LIB ${SUPPORT}/PCRE/lib
    ibek support add-config-macro ${NAME} PCRE_INCLUDE ${SUPPORT}/PCRE/include
else
    # prce developer library
    ibek support apt-install libpcre3-dev
    ibek support add-runtime-packages libpcre3

    # declare packages for installation in the Dockerfile's runtime stage
    ibek support add-runtime-packages libpcre3

    # declare location of the pcre system library
    ibek support add-config-macro ${NAME} PCRE_LIB /usr/lib/x86_64-linux-gnu
fi

# set CALC blank (to overwrite the RELEASE value) to build without calc
ibek support add-release-macro CALC --no-replace

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs stream
ibek support add-dbds stream-base.dbd stream.dbd

# dont build the docs
sed -i -E 's/(^[^#].*pdf.*$)/# \1/' ${SUPPORT}/${NAME}/Makefile

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


if [[ $EPICS_TARGET_ARCH == "RTEMS"* ]]; then
    # make pcre library available to the IOC (can this be done more cleanly?)
    cp ${SUPPORT}/PCRE/lib/libpcre.a ${SUPPORT}/${NAME}/lib/RTEMS-beatnik
fi
