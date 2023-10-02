#!/bin/bash

THIS_FOLDER=$(realpath $(dirname ${0}))
IBEK_SROOT=${THIS_FOLDER}/../


# make a global ioc schema for all the support modules combined
echo generating all support schema
ibek ioc generate-schema ${IBEK_SROOT}*/*.ibek.support.yaml --output /tmp/all.ibek.ioc.schema.json

# make ioc instance files for an ADAravis IOC instance using all the support modules
echo generating ioc instance files
ibek startup generate ${THIS_FOLDER}/ioc.yaml ${IBEK_SROOT}*/*.ibek.support.yaml --out /tmp/st.cmd --db-out /tmp/ioc.db
