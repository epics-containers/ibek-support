#!/bin/bash

set -xe

THIS_FOLDER=$(realpath $(dirname ${0}))
IBEK_SROOT=${THIS_FOLDER}/../

pip install "ibek>=1.7.1"

# make a global ioc schema for all the support modules combined
# this validates all ibek.support.yaml files
echo generating all support schema
ibek ioc generate-schema ${IBEK_SROOT}*/*.ibek.support.yaml --no-ibek-defs --output /tmp/all.ibek.ioc.schema.json

# make ioc instance files for an ADAravis IOC instance using all the support modules
# echo generating ioc instance files
# ibek runtime generate ${THIS_FOLDER}/ioc.yaml ${IBEK_SROOT}*/*.ibek.support.yaml --out /tmp/st.cmd --db-out /tmp/ioc.db
# TODO this only works inside a container now (since PVI integration) - should it??
# TODO propose we have a ec --epics-root ... to allow us to test this function outstide containers
