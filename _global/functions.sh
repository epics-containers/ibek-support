#!/bin/bash

# global functions for ibek-support to be called from install.sh in each
# support module directory

# establish where ibek-support global folder is located
GLOBALS_DIR="$( dirname "${BASH_SOURCE[0]}" )"

# log commands and exit on error
set -xe

# Fetch the source by tag -default repo is epics-modules
function git_clone_tag {
    NAME=${1}
    VERS=${2}
    REPO=${3:-https://github.com/epics-modules/}

    # clone the module if it doesn't already exist
    if [[ -d  ${SUPPORT}/${NAME} ]]; then
        echo "${NAME} exists. Skipping clone .."
    else
        git clone ${REPO}${NAME}.git --branch ${VERS} --depth 1 ${SUPPORT}/${NAME}
    fi

    cd ${SUPPORT}/${NAME}
}

# Updates RELEASE.local etc to enable compilation in epics-containers env
function write_local_files {
    NAME=${1}

    # Make RELEASE files to point to the correct paths by adding RELEASE.local
    python ${GLOBALS_DIR}/support.py fix-release ${NAME}

    # Apply any global patches (try to only add .local files as far as possible)
    bash ${GLOBALS_DIR}/global.sh
}

# Compile
function build_support_module {
    NAME=${1}

    # compile the support module
    make -C ${SUPPORT}/${NAME} -j $(nproc)
}

function create_links {
    NAME=${1}
    VERS=${2}

    # link bob files, ibek yaml files and pvi files to a global folder
    # (note that these may be versioned so link the correct version)

    # TODO
}

function not_required {
    # ARGS: list of macros for unrequired modules

    # Add the listed macros to the global release file if not already there
    python ${GLOBALS_DIR}/support.py not-required ${@}
}
