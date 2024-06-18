#!/bin/bash

set -xe

THIS_FOLDER=$(realpath $(dirname ${0}))
IBEK_SROOT=${THIS_FOLDER}/../

pip install --upgrade -r $IBEK_SROOT/requirements.txt

# make a global ioc schema for all the support modules combined
# this validates all ibek.support.yaml files
echo generating all support schema
ibek ioc generate-schema ${IBEK_SROOT}*/*.ibek.support.yaml --no-ibek-defs --output /tmp/all.ibek.ioc.schema.json

