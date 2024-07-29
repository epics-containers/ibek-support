#!/bin/bash

THIS_DIR=$(dirname $(readlink -f $0))

cd $THIS_DIR
ADCORE=/epics/support/ADCore

set -e

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
done
