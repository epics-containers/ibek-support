#!/usr/bin/env bash

# patch asyn for compatibility with the container base OS Ubuntu

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    # don't build the test directories (they don't compile on RTEMS)
    sed -i /'DIRS +='/s/tests// Makefile
fi

