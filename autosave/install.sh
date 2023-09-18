#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)

# get the name of this folder which is the same as name of the support module
NAME=$(basename $(dirname ${0}))
VERSION=${1}

IBEK_SUPPORT=$(realpath $(dirname ${0})/..)
source ${IBEK_SUPPORT}/_global/functions.sh

git_clone_tag ${NAME} ${VERSION}

support add-module-to-release ${NAME}

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
#### end of patch commands ###############################################
##########################################################################

global_fixes ${NAME}

build_support_module ${NAME}

create_links ${NAME}
