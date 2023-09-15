#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

NAME=iocStats

source /workspace/*/ibek-support/_global/functions.sh

git_clone_tag ${NAME} ${1}

##########################################################################
##### put your patch here if needed ######################################
##########################################################################

write_local_files ${NAME}
    # does python support.py fix-release ${NAME}
    # global.sh --> only does locals too

# compile the support module
make -C ${SUPPORT}/${NAME} -j $(nproc)

# link bob files
create_links ${NAME}