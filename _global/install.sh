#!/bin/bash

# global install script for support all support modules to reference

x86_cfg=${MODULE}/'configure/CONFIG_SITE.Common.linux-x86_64'
support_x86=${SUPPORT}/${NAME}/${x86_cfg}

# for RTEMS builds don't build for the host architecture, target only
if [[ $TARGET_ARCHITECTURE == "RTEMS"* ]]; then
    touch ${support_x86}
    sed -i '/VALID_BUILDS/d' ${support_x86}
    echo "VALID_BUILDS=Host" >> ${support_x86}
fi
