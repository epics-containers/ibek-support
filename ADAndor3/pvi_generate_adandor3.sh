#!/bin/bash

# Generate the PVI device files needed to make some basic auto-generated GUI for the ADAndor3 areaDetector plugins.

IBS=$(realpath $(dirname ${0}))
if [[ ${IBS} != /workspaces/*/ibek-support/ADAndor3 ]]; then
    echo "Must be run in ibek-support directory inside a container"
    exit 1
fi

if ! pvi --version; then
    echo "pvi not found"
    echo "please clone pvi into /repos and 'pip install -e /repos/pvi'"
    exit 1
fi

set -e

ADANDOR3=/epics/support/ADAndor3
cd ${IBS}

pvi convert device /workspaces/ioc-adandor3/ibek-support/ADAndor3  \
    --name ADAndor3 \
    --template /epics/support/ADAndor3/andor3App/Db/andor3.template

pvi regroup ADAndor3/ADAndor3.pvi.device.yaml ${ADANDOR3}/andor3App/op/adl/*.adl

ibek support generate-links $(pwd)
