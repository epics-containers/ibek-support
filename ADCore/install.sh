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
    libaec-dev \
    libblosc-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libtiff5-dev \
    libusb-1.0 \
    libxml2-dev \
    libx11-dev \
    libxext-dev \
    libz-dev \
    $HDF/libhdf5-103_1.10.4+repack-10_amd64.deb \
    $HDF/libhdf5-cpp-103_1.10.4+repack-10_amd64.deb \
    $HDF/libhdf5-dev_1.10.4+repack-10_amd64.deb

# declare packages for installation in the Dockerfile's runtime stage
ibek support apt-install --only=run libtiff5 libsz2 libblosc1 libxml2 libhdf5-103-1

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org http://github.com/areaDetector/
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs ntndArrayConverter ADBase NDPlugin pvAccessCA \
     pvAccessIOC pvAccess
ibek support add-dbds NDPluginPva.dbd ADSupport.dbd NDPluginSupport.dbd \
     NDFileNull.dbd NDPosPlugin.dbd NDFileHDF5.dbd NDFileJPEG.dbd NDFileTIFF.dbd \
     PVAServerRegister.dbd

# add any required changes to CONFIG_SITE
CONFIG='
AREA_DETECTOR=$(SUPPORT)
CROSS_COMPILER_TARGET_ARCHS =
WITH_GRAPHICSMAGICK = NO
WITH_HDF5     = YES
HDF5_EXTERNAL = YES
HDF5_LIB      = /usr/lib/x86_64-linux-gnu/hdf5/serial/
HDF5_INCLUDE  = /usr/include/hdf5/serial/
WITH_SZIP     = YES
SZIP_EXTERNAL = YES
WITH_JPEG     = YES
JPEG_EXTERNAL = YES
WITH_TIFF     = YES
TIFF_EXTERNAL = YES
XML2_EXTERNAL = YES
XML2_INCLUDE  = /usr/include/libxml2/
WITH_ZLIB     = YES
ZLIB_EXTERNAL = YES
WITH_BLOSC    = YES
BLOSC_EXTERNAL= YES
WITH_CBF      = YES
CBF_EXTERNAL  = YES
WITH_PVA      = YES
WITH_BOOST    = NO
'
ibek support add-to-config-site ${NAME} "${CONFIG}"

# compile the support module
ibek support compile ${NAME}

# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links


