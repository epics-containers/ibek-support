#!/bin/bash

# This script creates the global schemas for ibek-defs.
# It requires ibek to be installed.
#
# ibek.defs.schema.json is the schema for all **ibek.support.yaml files.
# all.ibek.support.schema.json is a global schema for **ibek.ioc.yaml files
#    which includes all the support schemas.

set -xe

THIS_DIR=$(realpath $(dirname ${0}))

cd $THIS_DIR

mkdir -p schemas

# Create the global schemas
ibek support generate-schema --output schemas/ibek.support.schema.json


# first do each support module's ioc schema individually to easily pick out errors
for i in */*.ibek.support.yaml; do
    ibek ioc generate-schema $i --output schemas/$(basename $i .ibek.support.yaml).ibek.ioc.schema.json
done

# now make a global ioc schema for all the support modules combined
ibek ioc     generate-schema */*.ibek.support.yaml --output schemas/all.ibek.ioc.schema.json
