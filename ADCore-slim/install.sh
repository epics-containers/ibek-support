#!/bin/bash
##########################################################################
##### install script for ADCore support module ###########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=ADCore

# log output and abort on failure
set -xe

# install required system dependencies
HDF=http://ftp.de.debian.org/debian/pool/main/h/hdf5
ibek support apt-install --only=dev \
    libglib2.0-dev \
    libxml2-dev \
    libx11-dev \
    libxext-dev

# declare packages for installation in the Dockerfile's runtime stage
ibek support apt-install --only=run  libxml2

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org http://github.com/areaDetector/
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs ntndArrayConverter ADBase NDPlugin pvAccessCA \
     pvAccessIOC pvAccess
ibek support add-dbds NDPluginPva.dbd ADSupport.dbd NDPluginSupport.dbd \
     NDFileNull.dbd PVAServerRegister.dbd

# add any required changes to CONFIG_SITE
CONFIG='
AREA_DETECTOR=$(SUPPORT)
CROSS_COMPILER_TARGET_ARCHS =
XML2_EXTERNAL = YES
XML2_INCLUDE  = /usr/include/libxml2
WITH_GRAPHICSMAGICK = NO
WITH_HDF5     = NO
WITH_SZIP     = NO
WITH_JPEG     = NO
WITH_TIFF     = NO
WITH_ZLIB     = NO
WITH_BLOSC    = NO
WITH_CBF      = NO
WITH_PVA      = YES
WITH_BOOST    = NO
'
ibek support add-to-config-site ${NAME} "${CONFIG}"

# Sequencer causes problems with the build so we disable it
ibek support add-release-macro SNCSEQ

# compile the support module
ibek support compile ${NAME}

# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${NAME}


