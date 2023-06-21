#!/bin/bash

# This script creates the global schemas for ibek-defs.
# It requires ibek to be installed.
#
# ibek.defs.schema.json is the schema for all **ibek.support.yaml files.
# all.ibek.support.schema.json is a global schema for **ibek.ioc.yaml files
#    which includes all the support schemas.

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $THIS_DIR

# Create the global schemas
ibek ibek-schema _global/ibek.defs.schema.json
ibek ioc-schema */*.support.yaml _global/all.ibek.support.schema.json
