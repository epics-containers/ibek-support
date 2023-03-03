#!/usr/bin/env bash

# patch asyn for compatibility with the container base OS Ubuntu

if [[ $TARGET_ARCHITECTURE != "rtems" ]]; then
    # Enable TIRPC for ASYN
    sed -i 's:# TIRPC:TIRPC:g' configure/CONFIG_SITE
else
    # don't build the test directories (they don't compile on RTEMS)
    sed -i '/DIRS += .*test/d' Makefile
fi

# remove dependency on IPAC support
sed -i 's:IPAC=:# IPAC=:g' configure/RELEASE