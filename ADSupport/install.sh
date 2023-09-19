#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}

# get the name of this folder, i.e. the name of the support module
NAME=$(basename $(dirname ${0}))

ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}
ibek support add-libs ${NAME} TODO
ibek support add-dbds ${NAME} TODO.dbd

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

echo '
AREA_DETECTOR=$(SUPPORT)

CROSS_COMPILER_TARGET_ARCHS =

# Enable file plugins and source them all from ADSupport
# this minimizes dependency issues with system libraries

WITH_GRAPHICSMAGICK = YES
GRAPHICSMAGICK_EXTERNAL = NO

WITH_HDF5     = YES
HDF5_EXTERNAL = NO

WITH_SZIP     = YES
SZIP_EXTERNAL = NO

WITH_JPEG     = YES
JPEG_EXTERNAL = NO

WITH_TIFF     = YES
TIFF_EXTERNAL = NO

XML2_EXTERNAL = NO

WITH_ZLIB     = YES
ZLIB_EXTERNAL = NO

WITH_BLOSC    = YES
BLOSC_EXTERNAL= NO

WITH_CBF      = YES
CBF_EXTERNAL  = NO

WITH_PVA      = YES
WITH_BOOST    = YES
' >> configure/CONFIG_SITE.linux-x86_64.Common

##########################################################################
#### end of patch commands ###############################################
##########################################################################

ibek support compile ${NAME}
ibek support generate-links ${NAME}


