#!/bin/bash

# auto generate PVI device files for all of ADCore

IBS=$(realpath $(dirname ${0}))
if [[ ${IBS} != /workspaces/*/ibek-support/ADCore ]]; then
    echo "Must be run an ibek-suppport directory inside a container"
    exit 1
fi

if ! pvi --version; then
    echo "pvi not found"
    echo "please clone pvi into /repos and 'pip install -e /repos/pvi'"
    exit 1
fi

set -e

ADCORE=/epics/support/ADCore
cd ${IBS}

blacklist="
NDAttrPlotAttr.template
NDAttrPlotData.template
NDGatherN.template
NDStdArrays.template
"

pvi convert device --name ADCore --template ${ADCORE}/db/ADBase.template .
pvi regroup ADDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

for nd in $ADCORE/db/ND*.template; do
    name=$(basename $nd .template)
    if [[ $blacklist == *"$name".template* ]] ; then
        echo "Skipping $name"
        continue
    fi
    echo ">>>>>>>>>> Processing $name <<<<<<<<<<"
    # maybe add --template ${ADCORE}/db/NDFile.template for NDFileXXX plugins ?
    pvi convert device --name $name --template $nd .
    pvi regroup NDPluginDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl
done

ibek support generate-links ADCore