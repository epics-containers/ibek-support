#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)

NAME=asyn
VERSION=${1}

IBEK_SUPPORT=$(realpath $(dirname ${0})/..)
source $IBEK_SUPPORT/_global/functions.sh

git_clone_tag ${NAME} ${VERSION}

# No need for IPAC unless its already installed
not_required IPAC

write_local_files ${NAME}

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################

if [[ $TARGET_ARCHITECTURE != "rtems" ]]; then
    # Enable TIRPC for ASYN
    echo TIRPC=YES > configure/CONFIG_SITE.local
else
    # don't build the test directories (they don't compile on RTEMS)
    sed -i '/DIRS += .*test/d' Makefile
fi


##########################################################################
#### end of patch commands ###############################################
##########################################################################


build_support_module ${NAME}

create_links ${NAME}

