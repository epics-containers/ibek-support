#!/bin/bash

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
VERSION=${1}
NAME=snmp
FOLDER=$(dirname $(readlink -f $0))

# log output and abort on failure
set -xe

ibek support apt-install libsnmp-dev
ibek support add-runtime-packages libsnmp40

# get the source and fix up the configure/RELEASE files
ibek support git-clone ${NAME} ${VERSION} --org https://github.com/slac-epics/
ibek support register ${NAME}

# declare the libs and DBDs that are required in ioc/iocApp/src/Makefile
ibek support add-libs devSnmp
ibek support add-dbds devSnmp.dbd snmp.dbd

# underlying snmp library installed above is in standard location
ibek support add-config-macro ${NAME} NET_SNMP_PKG
ibek support add-config-macro ${NAME} USR_INCLUDES
ibek support add-config-macro ${NAME} USR_LDFLAGS

# global config settings
${FOLDER}/../_global/install.sh ${NAME}

# compile the support module
ibek support compile ${NAME}
# prepare *.bob, *.pvi, *.ibek.support.yaml for access outside the container.
ibek support generate-links ${FOLDER}


