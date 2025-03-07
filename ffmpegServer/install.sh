#!/bin/bash
##########################################################################
###### install script for ffmpegServer Module ###########################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=ffmpegServer
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

# install required system dependencies
ibek support apt-install ffmpeg libavcodec-dev libswscale-dev libavformat-dev libavdevice-dev

# declare packages for installation in the Dockerfile's runtime stage
ibek support add-runtime-packages ffmpeg

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org http://github.com/areaDetector/
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs ffmpegServer
ibek support add-dbds ffmpegServer.dbd

# comment out the vendor directory from the Makefiles
sed -i -E 's/(^[^#].*(vendor).*$)/# \1/' ${SUPPORT}/${NAME}/Makefile
sed -i -E 's/(^[^#].*(vendor\/ffmpeg).*$)/# \1/' ${SUPPORT}/${NAME}/${NAME}App/src/Makefile
# re-define the external ffmpeg libraries to be used when linking the ffmpegServer library
sed -i "/\bav.*/ s/LIB/${NAME}_SYS/1" ${SUPPORT}/${NAME}/${NAME}App/src/Makefile

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}
