#!/bin/bash
##########################################################################
###### install script for delta tau pmac module ##########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=pmac
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org http://github.com/dls-controls/
ibek support register ${NAME}

# original CONFIG_SITE/RELEASE....Common have dls paths - TODO add --overwrite to
# 'ibek support add-to-config-site'
rm -f /epics/support/pmac/configure/CONFIG_SITE.linux-x86_64.Common
rm -f /epics/support/pmac/configure/RELEASE.linux-x86_64.Common

if [[ ! $EPICS_TARGET_ARCH == "RTEMS"* ]]; then

    ibek support apt-install libssh2-1-dev
    ibek support add-runtime-packages libssh2-1

    CONFIG="
# The following definitions must be changed for each site

#     - To build the IOC applications set BUILD_IOCS to YES
#       Otherwise set it to NO
BUILD_IOCS=NO

# Definitions required for compiling the unit tests
BOOST_LIB       = /usr/lib
BOOST_INCLUDE   = -I/usr/include

SSH             = /usr
SSH_LIB         = /usr/lib/x86_64-linux-gnu
SSH_INCLUDE     = -I/usr/include
"

    ibek support add-to-config-site ${NAME} "${CONFIG}"

fi

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs pmacAsynIPPort pmacAsynMotorPort
ibek support add-dbds pmacAsynIPPort.dbd pmacAsynMotorPort.dbd

if [[ ! $EPICS_TARGET_ARCH == "RTEMS"* ]]; then
    ibek support add-libs powerPmacAsynPort
    ibek support add-dbds drvAsynPowerPMACPort.dbd
fi

# comment out the test directories from the Makefile
sed -i -E 's/(^[^#].*(Tests).*$)/# \1/' ${SUPPORT}/${NAME}/pmacApp/Makefile

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module (don't build parallel as Makefile doesn't work)
ibek support compile ${NAME} -j 1
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


