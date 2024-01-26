#!/bin/bash
##########################################################################
###### install script for OPCUA Module ###################################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=opcua
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

ibek support apt-install --only=dev cmake libxml2-dev libssl-dev
ibek support apt-install --only=run libxml2

# the 'if' speeds up retries in the devcontainer. remove the folder to rebuild
if [ ! -d /tmp/open62541 ]; then
(
    cd /tmp
    git clone https://github.com/open62541/open62541.git -b v1.3.9 --depth 1
    cd open62541
    mkdir build
    cd build
    cmake .. -DBUILD_SHARED_LIBS=ON \
         -DCMAKE_BUILD_TYPE=RelWithDebInfo \
         -DUA_ENABLE_ENCRYPTION=OPENSSL
    make install
)
fi

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION}
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs opcua
ibek support add-dbds opcuaItemRecord.dbd menuDefAction.dbd devOpcua.dbd

# config site settings for linking with Open62541
CONFIG='
# Path to the Open62541 C++ installation
OPEN62541 = /usr/local

# How the Open62541 shared libraries are deployed
#   SYSTEM = shared libs are in a system location
#   PROVIDED = shared libs are in $(OPEN62541_SHRLIB_DIR)
#   INSTALL = shared libs are installed (copied) into this module
#   EMBED = link Open62541 code statically into libopcua,
#           the Open62541 libraries are not required on target system
OPEN62541_DEPLOY_MODE = PROVIDED
OPEN62541_LIB_DIR = $(OPEN62541)/lib
OPEN62541_SHRLIB_DIR = $(OPEN62541_LIB_DIR)
# How the Open62541 libraries were built
OPEN62541_USE_CRYPTO = YES
'
ibek support add-to-config-site ${NAME} "${CONFIG}"

# all the DB templates are in a subfolder - expose them in std location
ln -s /epics/support/${NAME}/exampleTop/db ${NAME}/db

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}

