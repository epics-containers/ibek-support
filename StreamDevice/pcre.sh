#!/bin/bash

if [[ $EPICS_TARGET_ARCH == "RTEMS"* ]]; then

    ibek support add-libs pcre

    cd /epics/support/StreamDevice

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
fi