#!/bin/bash

THIS_DIR=$(dirname $(readlink -f $0))

cd $THIS_DIR
ADCORE=/epics/support/ADCore

set -e

# pvi needs to know which type of waveform to use so this is an unfortunate
# workaround for now and note that the resulting pvi device will allways use
# int32 waveform
sed -i s/\$\(TYPE\)/Int32/g ${ADCORE}/db/NDStdArrays.template

# We are not yet supporting the xxxN templates
# the base templates are handled separately
skip="
NDArrayBase
NDAttrPlotAttr
NDAttrPlotData
NDAttributeN
NDGatherN
NDOverlayN
NDPluginBase
NDROIStat8
NDROIStatN
NDTimeSeriesN
"

for i in $ADCORE/db/ND*.template ; do

    name=$(basename ${i} .template)

    # not all templates are for devices
    if [[ ${skip} =~ ${name} ]] ; then
        echo 'skipping' ${name}; continue
    else
        echo generating pvi device for $name
    fi

    pvi convert device --template $i . ${ADCORE}/ADApp/pluginSrc/ND*${name#"ND"}.h
    pvi regroup ND*${name#"ND"}.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl
done

# handle the base templates ####################################################

pvi convert device --template ${ADCORE}/db/NDArrayBase.template . ${ADCORE}/ADApp/ADSrc/asynNDArrayDriver.h
pvi regroup asynNDArrayDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --template ${ADCORE}/db/ADBase.template . ${ADCORE}/ADApp/ADSrc/ADDriver.h
pvi regroup ADDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --template ${ADCORE}/db/NDPluginBase.template . ${ADCORE}/ADApp/pluginSrc/NDPluginDriver.h
pvi regroup NDPluginDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl
