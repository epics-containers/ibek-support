#!/bin/bash

# patch pmac for compatibility with the container base OS

echo "
# The following definitions must be changed for each site

#     - To build the IOC applications set BUILD_IOCS to YES
#       Otherwise set it to NO
BUILD_IOCS=NO

CROSS_COMPILER_TARGET_ARCHS =

# Definitions required for compiling the unit tests
BOOST_LIB       = /usr/lib
BOOST_INCLUDE   = -I/usr/include

SSH             = /usr
SSH_LIB         = /usr/lib/x86_64-linux-gnu
SSH_INCLUDE     = -I/usr/include
" > configure/CONFIG_SITE.linux-x86_64.Common

# don't build the test directories (they don't compile on RTEMS)
sed -i '/DIRS += .*unitTests/d' pmacApp/Makefile

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    echo "
VALID_BUILDS=Host
" > configure/CONFIG_SITE.linux-x86_64.Common
fi