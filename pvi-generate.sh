#!/bin/bash

# this script is used to generate the PVI files needed to make some basic
# auto generated GUI for currently supported Generic IOCs. In particular
# AreaDetector ones as these are moderately complex.
#
# This is used as a record of the steps to take to get these files
# created but can be retired once we are happy with the device yaml in
# any given support module.
#
# note the sed commands - some of these may get fixed in pvi and not longer
# be needed, others may be premanent manual edits.
#
# NOTE: what is not inlcuded in any script yet is the addition of the pvi:
# entry into *.ibek.support.yaml. These are required in order for the
# ibek runtime generate to turn the device yaml into bob files.
# This means that re-running build_support.sh would delete these entries.

cd dirname ${0}

IBS=$(realpath $(pwd))
if [[ ${IBS} != /epics/*/ibek-support ]]; then
    echo "Must be run an ibek-suppport directory inside a container"
    exit 1
fi

if not pvi --version; then
    echo "pvi not found"
    echo "please clone pvi into /repos and 'pip install -e /repos/pvi'"
    exit 1
fi

set -e

ADCORE=/epics/support/ADCore
cd ${IBS}/ADCore

pvi convert device --template ${ADCORE}/db/NDProcess.template . ${ADCORE}/ADApp/pluginSrc/NDPluginProcess.h
pvi regroup NDPluginProcess.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --template ${ADCORE}/db/NDStats.template . ${ADCORE}/ADApp/pluginSrc/NDPluginStats.h
pvi regroup NDPluginStats.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --template ${ADCORE}/db/NDROI.template . ${ADCORE}/ADApp/pluginSrc/NDPluginROI.h
pvi regroup NDPluginROI.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --template ${ADCORE}/db/ADBase.template . ${ADCORE}/ADApp/ADSrc/ADDriver.h
pvi regroup ADDriver.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --template ${ADCORE}/db/NDPva.template . ${ADCORE}/ADApp/pluginSrc/NDPluginPva.h
pvi regroup NDPluginPva.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

pvi convert device --template ${ADCORE}/db/NDFileHDF5.template --template ${ADCORE}/db/NDFile.template . ${ADCORE}/ADApp/pluginSrc/NDFileHDF5.h
pvi regroup NDFileHDF5.pvi.device.yaml ${ADCORE}/ADApp/op/adl/*.adl

ADGenICam=/epics/support/ADGenICam
cd ${ADGenICam}
./addCamera.sh AVT_Manta_1_44
./addCamera.sh AVT_Mako_1_52

cd ${IBS}/ADGenICam

# TODO this does not work yet - see https://github.com/epics-containers/pvi/issues/61
pvi convert device --template ${ADGenICam}/GenICamApp/Db/AVT_Manta_1_44.template . ${ADGenICam}/GenICamApp/src/ADGenICam.h
pvi regroup ADGenICam.pvi.device.yaml ${ADGenICam}/GenICamApp/op/adl/*.adl
mv ADGenICam.pvi.device.yaml AVT_Manta_1_44.pvi.device.yaml

pvi convert device --template ${ADGenICam}/GenICamApp/Db/AVT_Mako_1_52.template . ${ADGenICam}/GenICamApp/src/ADGenICam.h
pvi regroup ADGenICam.pvi.device.yaml ${ADGenICam}/GenICamApp/op/adl/*.adl
mv ADGenICam.pvi.device.yaml AVTMako152.pvi.device.yaml
sed -i AVTMako152.pvi.device.yaml -e 's/AVT_Mako_1_52/AVTMako152/' -e '

pvi convert device --template ${ADGenICam}/db/ADGenICam.template . ${ADGenICam}/GenICamApp/src/ADGenICam.h
pvi regroup ADGenICam.pvi.device.yaml ${ADGenICam}/GenICamApp/op/adl/*.adl

ADARAVIS=/epics/support/ADAravis
cd ${IBS}/ADAravis

pvi convert device --template ${ADARAVIS}/db/aravisCamera.template . ${ADARAVIS}/aravisApp/src/arvFeature.h
sed -i arvFeature.pvi.device.yaml -e s/aravisCamera/AravisCamera/
pvi regroup arvFeature.pvi.device.yaml ${ADARAVIS}/aravisApp/op/adl/*.adl

# these commands link all the device yamls into /epics/pvi-defs
ibek support generate-links ADCore
ibek support generate-links ADAravis
ibek support generate-links ADGenICam
