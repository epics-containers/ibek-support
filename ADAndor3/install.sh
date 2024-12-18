#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=ADAndor3
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

ibek support apt-install libnuma-dev
ibek support add-runtime-packages libnuma-dev

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/areaDetector
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
# ibek support add-dbds shamrockSupport.dbd andorCCDSupport.dbd
# ibek support add-libs andorCCD

# remove dls specific RELEASE files
rm -f ${SUPPORT}/${NAME}/configure/RELEASE.linux-x86_64.Common

# add any required changes to CONFIG_SITE
CONFIG='
SZIP_LIB       = /usr/lib/x86_64-linux-gnu/
SZIP_INCLUDE   = -I/usr/include

HDF5_LIB      = /usr/lib/x86_64-linux-gnu/hdf5/serial/
HDF5_INCLUDE  = /usr/include/hdf5/serial/
'

ibek support add-to-config-site ${NAME} "${CONFIG}"

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs atcore andor3
ibek support add-dbds andor3Support.dbd

# global config settings
${FOLDER}/../../ibek-support/_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}

ln -s /dev/video0 /dev/andor3pci
