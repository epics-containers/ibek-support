#!/bin/bash

# Generate the PVI device files needed to make some basic auto-generated GUI for the ffmpegServer areaDetector plugins.

IBS=$(realpath $(dirname ${0}))
if [[ ${IBS} != /workspaces/*/ibek-support/ffmpegServer ]]; then
    echo "Must be run in ibek-suppport directory inside a container"
    exit 1
fi

if ! pvi --version; then
    echo "pvi not found"
    echo "please clone pvi into /repos and 'pip install -e /repos/pvi'"
    exit 1
fi

set -e

FFMPEGSERVER=/epics/support/ffmpegServer
cd ${IBS}

pvi convert device --name ffmpegFile --parent NDPluginBase --template ${FFMPEGSERVER}/db/ffmpegFile.template .
pvi regroup ffmpegFile.pvi.device.yaml ${FFMPEGSERVER}/ffmpegServerApp/op/adl/*.adl

pvi convert device --name ffmpegStream --parent NDPluginBase --template ${FFMPEGSERVER}/db/ffmpegStream.template .
pvi regroup ffmpegStream.pvi.device.yaml ${FFMPEGSERVER}/ffmpegServerApp/op/adl/*.adl

ibek support generate-links $(pwd)
