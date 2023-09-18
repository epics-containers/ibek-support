#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)

NAME=autosave
VERSION=${1}

IBEK_SUPPORT=$(realpath $(dirname ${0})/..)
source ${IBEK_SUPPORT}/_global/functions.sh

git_clone_tag ${NAME} ${VERSION}

write_local_files ${NAME}

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

if [[ $TARGET_ARCHITECTURE == "rtems" ]]; then
    echo "Patching RTEMS autosave"
    patch -p1 < ${THIS_DIR}/rtems-autosave.patch

    echo >> configure/CONFIG_SITE.Common.linux-x86_64
    echo "VALID_BUILDS=Host" >> configure/CONFIG_SITE.Common.linux-x86_64
fi

##########################################################################

build_support_module ${NAME}

create_links ${NAME}
