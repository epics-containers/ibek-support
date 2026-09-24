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
# Int32 waveform
cp ${ADCORE}/db/NDStdArrays.template ${ADCORE}/db/NDStdArraysOriginal.template
sed -i s/\$\(TYPE\)/Int32/g ${ADCORE}/db/NDStdArrays.template

template_sets="
NDAttrPlotAttr
NDAttrPlotData
NDGatherN,None
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

# These device files were regrouped by hand in #158 and are now the source of
# truth, so they must not be regenerated. `pvi reconvert` adds PVs from a new or
# updated template to an existing device file without touching its grouping.
hand_grouped=" ADDriver NDArrayBase NDPluginBase NDFile NDFileHDF5 "

# make_device <name> <template> [<extra pvi convert args> ...]
make_device() {
    local name=$1 template=$2
    shift 2

    if [[ ${hand_grouped} == *" ${name} "* && -f ${name}.pvi.device.yaml ]]; then
        (
            set -x
            pvi reconvert ${name}.pvi.device.yaml --template ${template}
        )
        return
    fi

    (
        set -x
        pvi convert device --name ${name} \
          --template ${template} \
          "$@" .
    )
    pvi regroup ${name}.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl
}

make_device ADDriver ${ADCORE}/db/ADBase.template --parent NDArrayBase
make_device NDArrayBase ${ADCORE}/db/NDArrayBase.template
make_device NDPluginBase ${ADCORE}/db/NDPluginBase.template --parent NDArrayBase

for template_set in $template_sets; do

    # use commas to split the template set into a bash array
    templates=(${template_set//,/ })
    name=${templates[0]}
    parent=
    if [[ ${templates[1]} != "None" ]]; then
        parent="--parent ${templates[1]:-NDPluginBase}"
    fi

    make_device ${name} ${ADCORE}/db/${name}.template ${parent}

done

# restore the original STDArrays template
mv ${ADCORE}/db/NDStdArraysOriginal.template ${ADCORE}/db/NDStdArrays.template

ibek support generate-links $(pwd)
