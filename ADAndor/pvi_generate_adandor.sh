#!/bin/bash

# Generate the PVI device files needed to make some basic auto-generated GUI for the ADAndor areaDetector plugins.

IBS=$(realpath $(dirname ${0}))
if [[ ${IBS} != /workspaces/*/ibek-support/ADAndor ]]; then
    echo "Must be run in ibek-support directory inside a container"
    exit 1
fi

if ! pvi --version; then
    echo "pvi not found"
    echo "please clone pvi into /repos and 'pip install -e /repos/pvi'"
    exit 1
fi

set -e

ADANDOR=/epics/support/ADAndor
cd ${IBS}

pvi convert device /workspaces/ioc-adandor/ibek-support/ADAndor  \
    --name ADAndor \
    --header /epics/support/ADAndor/andorApp/src/andorCCD.h \
    --template /epics/support/ADAndor/andorApp/Db/andorCCD.template \
    # pvi definition is missing waveform conversion for records with 'asynFloat32ArrayIn' DTYP
    # --template /epics/support/ADAndor/andorApp/Db/shamrock.template

pvi regroup ADAndor/ADAndor.pvi.device.yaml ${ADANDOR}/andorApp/op/adl/*.adl

ibek support generate-links $(pwd)
