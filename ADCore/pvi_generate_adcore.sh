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
NDROI
NDROIStat
NDROIStatN,None
NDScatter
NDStats
NDStdArrays
NDTimeSeries
NDTimeSeriesN,None
NDTransform
"

# These device files have been edited by hand since they were last generated
# (regrouped in #158 and its follow-up commits; NDPvxs added in 654c18a) and are
# now the source of truth, so they must not be regenerated with convert+regroup.
#
# `pvi reconvert` keeps the existing children untouched and appends one group,
# named after the template, holding every template signal it could not match
# against a top-level group child. That is the genuinely new PVs, but ALSO
# duplicates of any signal the hand edit moved into a nested group (SubScreen,
# Row) or renamed, so the appended group must be reconciled by hand afterwards.
hand_grouped=" ADDriver NDArrayBase NDPluginBase NDFile NDFileHDF5 NDProcess NDPvxs"
hand_grouped+=" NDROI NDROIStat NDROIStatN NDStats NDStdArrays NDTimeSeries "

# make_device <name> <template> [<extra pvi convert args> ...]
make_device() {
    local name=$1 template=$2
    shift 2

    if [[ ${hand_grouped} == *" ${name} "* && -f ${name}.pvi.device.yaml ]]; then
        (
            set -x
            pvi reconvert ${name}.pvi.device.yaml --template ${template}
        )
        echo "NOTE: ${name}.pvi.device.yaml is hand maintained: reconcile the" \
             "group appended by pvi reconvert by hand (see comment above)" >&2
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

# NDPluginPvxs is driven by NDPva.template, so its name does not match the template
make_device NDPvxs ${ADCORE}/db/NDPva.template

# restore the original STDArrays template
mv ${ADCORE}/db/NDStdArraysOriginal.template ${ADCORE}/db/NDStdArrays.template

ibek support generate-links $(pwd)
