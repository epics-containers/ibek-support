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

# pvi needs to know which type of waveform to use so this is an unfortunate
# workaround for now and note that the resulting pvi device will allways use
# int32 waveform (is this still needed?)
# sed -i s/\$\(TYPE\)/Int32/g ${ADCORE}/db/NDStdArrays.template

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

pvi convert device --name asynNDArrayDriver --template ${ADCORE}/db/NDArrayBase.template .
pvi regroup asynNDArrayDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

base="--template ${ADCORE}/db/NDArrayBase.template"

for nd in $ADCORE/db/ND*.template; do
    name=$(basename $nd .template)

    if [[ $blacklist == *"$name".template* ]] ; then
        echo ">>>>>>>>>> Skipping $name <<<<<<<<<<"
        continue
    fi

    if [[ $name == *File* ]] ; then
        f="--template ${ADCORE}/db/NDFile.template"
    else
        f=""
    fi

    echo ">>>>>>>>>> Processing $name <<<<<<<<<<"

    # maybe add --template ${ADCORE}/db/NDFile.template for NDFileXXX plugins ?
    pvi convert device --name $name $base $f --template $nd  .
    pvi regroup $name.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl
done

ibek support generate-links ADCore