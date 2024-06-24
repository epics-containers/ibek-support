#!/bin/bash

set -e

UPDATE=$1

THIS_FOLDER=$(realpath $(dirname ${0}))
IBEK_SROOT=${THIS_FOLDER}/../

# make a global ioc schema for all the support modules combined
# this validates all ibek.support.yaml files
echo generating all support schema
ibek ioc generate-schema ${IBEK_SROOT}*/*.ibek.support.yaml --no-ibek-defs --output /tmp/all.ibek.ioc.schema.json

# prepare an EPICS_ROOT for the runtime asset generation
rm -fr /tmp/epics
mkdir -p /tmp/epics/runtime
mkdir -p /tmp/epics/pvi-defs
cp $IBEK_SROOT/*/*.pvi.device.yaml /tmp/epics/pvi-defs

function asset_check () {
    if [[ $UPDATE = "update" ]] ; then
        echo "updating $1"
        rm -fr $THIS_FOLDER/outputs/$1
        mkdir -p $THIS_FOLDER/outputs/$1
        cp /tmp/epics/runtime/* $THIS_FOLDER/outputs/$1
    else
        if ! diff /tmp/epics/runtime $THIS_FOLDER/outputs/$1; then
            echo "runtime assets for $1 are out of date"
            FAILURE=TRUE
        fi
    fi
}

# find all ioc's with ibek ioc yaml and generate runtime assets for each
for ioc in $THIS_FOLDER/ioc_repos/*/services/*; do
    ioc_name=$(basename $ioc)
    ioc_config=$ioc/config/ioc.yaml

    if [[ -f $ioc_config ]] ; then
        echo generating runtime assets for $ioc_name
        export EPICS_ROOT=/tmp/epics
        if ! ibek runtime generate $ioc_config ${IBEK_SROOT}*/*.ibek.support.yaml
        then
        FAILURE=TRUE
        else
        asset_check $ioc_name
        fi
    else
        echo "skipping $ioc ..."
    fi
done

# return error if any of the runtime asset generations failed
if [[ $FAILURE = "TRUE" ]] ; then
  echo "Failed to generate runtime assets for some IOCs - see above"
  exit 1
fi
