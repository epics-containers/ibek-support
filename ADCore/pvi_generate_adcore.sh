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

# pvi needs to know which type of waveform to use so this is an unfortunate
# workaround for now and note that the resulting pvi device will allways use
# int32 waveform
sed -i s/\$\(TYPE\)/Int32/g ${ADCORE}/db/NDStdArrays.template

# these do not convert - throw PVI errors - TODO investigate
blacklist="
NDAttrPlotAttr.template
NDAttrPlotData.template
NDGatherN.template
"

template_sets="
NDFile
CCDMultiTrack
NDAttrPlot
NDAttribute
NDAttributeN,None
NDBadPixel
NDCircularBuff
NDCodec
NDColorConvert
NDFFT
NDFileHDF5,NDFile
NDFileJPEG,NDFile
NDFileMagick,NDFile
NDFileNetCDF,NDFile
NDFileNexus,NDFile
NDFileTIFF,NDFile
NDGather
NDOverlay
NDOverlayN,None
NDPosPlugin
NDProcess
NDPva
NDROI
NDROIStat
NDROIStat8,None
NDROIStatN,None
NDScatter
NDStats
NDStdArrays
NDTimeSeries
NDTimeSeriesN,None
NDTransform
"

pvi convert device --name ADDriver --parent NDArrayBase --template ${ADCORE}/db/ADBase.template .
pvi regroup ADDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --name NDArrayBase --template ${ADCORE}/db/NDArrayBase.template .
pvi regroup NDArrayBase.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --name NDPluginBase --parent NDArrayBase --template ${ADCORE}/db/NDPluginBase.template .
pvi regroup NDPluginBase.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

for template_set in $template_sets; do

    # use commas to split the template set into a bash array
    templates=(${template_set//,/ })
    name=${templates[0]}
    parent=
    if [[ ${templates[1]} != "None" ]]; then
        parent="--parent ${templates[1]:-NDPluginBase}"
    fi

    (
        set -x
        pvi convert device --name ${name} \
          --template ${ADCORE}/db/${name}.template \
          ${parent} .
    )
    pvi regroup ${name}.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

done

ibek support generate-links $(pwd)
