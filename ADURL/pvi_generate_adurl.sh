#!/bin/bash

# auto generate PVI device files for ADURL

IBS=$(realpath $(dirname ${0}))

if ! pvi --version; then
    echo "pvi not found"
    echo "please clone pvi into /repos and 'pip install -e /repos/pvi'"
    exit 1
fi

set -e

ADURL=/epics/support/ADURL
cd ${IBS}

pvi convert device --name ADURL --parent NDArrayBase --template ${ADURL}/db/URLDriver.template .
pvi regroup ADURL.pvi.device.yaml ${ADURL}/urlApp/op/adl/*.adl

ibek support generate-links $(pwd)
