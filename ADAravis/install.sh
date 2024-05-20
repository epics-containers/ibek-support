#!/bin/bash

##########################################################################
##### install script for ADAravis support module##########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=ADAravis
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# install required system dependencies
ibek support apt-install \
    libxext-dev \
    libglib2.0-dev \
    libusb-1.0 \
    libxml2-dev \
    libx11-dev \
    meson \
    intltool \
    pkg-config \
    xz-utils

# declare packages for installation in the Dockerfile's runtime stage
ibek support add-runtime-packages libglib2.0-bin libusb-1.0 libxml2 aravis-tools-cli

# build aravis library
(
    cd /usr/local &&
    git clone -b "0.8.31" --depth 1 https://github.com/AravisProject/aravis &&
    cd aravis &&
    meson build &&
    cd build &&
    ninja &&
    ninja install &&
    rm -fr /usr/local/aravis
    echo /usr/local/lib64 > /etc/ld.so.conf.d/usr.conf &&
    cd &&
    ldconfig
)

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org http://github.com/areaDetector/
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs ADAravis
ibek support add-dbds ADAravisSupport.dbd

# add any required changes to CONFIG_SITE
CONFIG='
CHECK_RELEASE=WARN
AREA_DETECTOR=/epics/support
CROSS_COMPILER_TARGET_ARCHS =
GLIBPREFIX=/usr
USR_INCLUDES += -I$(GLIBPREFIX)/include/glib-2.0
USR_INCLUDES += -I$(GLIBPREFIX)/lib/x86_64-linux-gnu/glib-2.0/include/
glib-2.0_DIR = $(GLIBPREFIX)/lib/x86_64-linux-gnu
ARAVIS_INCLUDE  = /usr/local/include/aravis-0.8/
'

# Hack to remove incorrectly placed include of ADGENICAM
sed -i '/ADGENICAM/d' ${SUPPORT}/ADAravis/configure/RELEASE

ibek support add-to-config-site ${NAME} "${CONFIG}"

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}

# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}
