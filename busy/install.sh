#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

# ARGUMENTS:
#  $1 VERSION to install (must match repo tag)
#  $2 REPOSITORY PATH defaults to epics-modules on github

# get the name of this folder which is the same as name of the support module
NAME=$(basename $(dirname ${0}))
VERSION=${1}

IBEK_SUPPORT=$(realpath $(dirname ${0})/..)
source $IBEK_SUPPORT/_global/functions.sh

git_clone_tag ${NAME} ${VERSION}

# No need for IPAC unless its already installed
add_to_release IPAC --remove

add_to_release ${NAME}

##########################################################################
##### put patch commands here if needed ##################################
##########################################################################


build_support_module ${NAME}

create_links ${NAME}

