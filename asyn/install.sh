#!/bin/bash
##########################################################################
##### boilerplate install script for support modules #####################
##########################################################################

NAME=asyn

source /workspace/ibek-support/_global/functions.sh

git_clone_tag ${NAME} ${1}

##########################################################################
##### put your patch here if needed ######################################
##########################################################################

if [[ $TARGET_ARCHITECTURE != "rtems" ]]; then
    # Enable TIRPC for ASYN
    echo TIRPC=YES > configure/CONFIG_SITE.local
else
    # don't build the test directories (they don't compile on RTEMS)
    sed -i '/DIRS += .*test/d' Makefile
fi

# remove dependency on IPAC support
echo IPAC= > configure/RELEASE.local

##########################################################################
#### end of patches ######################################################
##########################################################################

write_local_files ${NAME}
    # does python support.py fix-release ${NAME}
    # global.sh --> only does locals too

# compile the support module
make -C ${SUPPORT}/${NAME} -j $(nproc)

# link bob files
create_links ${NAME}

