#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

apt-get install -y --no-install-recommends \
    libaec-dev \
    libblosc-dev \
    libglib2.0-dev \
    libjpeg-dev \
    libtiff5-dev \
    libusb-1.0 \
    libxml2-dev \
    libx11-dev \
    libxext-dev \
    libz-dev
(
    cd tmp ;\
    wget http://ftp.de.debian.org/debian/pool/main/h/hdf5/libhdf5-cpp-103_1.10.4+repack-10_amd64.deb ;\
    wget http://ftp.de.debian.org/debian/pool/main/h/hdf5/libhdf5-103_1.10.4+repack-10_amd64.deb ;\
    wget http://ftp.de.debian.org/debian/pool/main/h/hdf5/libhdf5-dev_1.10.4+repack-10_amd64.deb ;\
    apt-get -y install ./libhdf5-103_1.10.4+repack-10_amd64.deb ;\
    apt-get -y install ./libhdf5-cpp-103_1.10.4+repack-10_amd64.deb ;\
    apt-get -y install ./libhdf5-dev_1.10.4+repack-10_amd64.deb
)
# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
#  $CONFIG text to add to configure/CONFIG_SITE.Common.linux-x86_64
VERSION=${1}

set -xe
# get the name of this folder, i.e. the name of the support module
NAME=$(basename $(dirname ${0}))

ibek support git-clone ${NAME} ${VERSION} --org http://github.com/areaDetector/
ibek support register ${NAME}

ibek support add-libs ntndArrayConverter ADBase NDPlugin pvAccessCA \
     pvAccessIOC pvAccess

ibek support add-dbds NDPluginPva.dbd ADSupport.dbd NDPluginSupport.dbd \
     NDFileNull.dbd NDPosPlugin.dbd NDFileHDF5.dbd NDFileJPEG.dbd NDFileTIFF.dbd \
     PVAServerRegister.dbd

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

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

##########################################################################
#### end of patch commands ###############################################
##########################################################################

ibek support compile ${NAME}
ibek support generate-links ${NAME}


