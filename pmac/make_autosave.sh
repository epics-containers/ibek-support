#!/bin/bash

THIS_DIR=$(realpath $(dirname $0))
cd $THIS_DIR

builder2ibek autosave /dls_sw/prod/R3.14.12.7/support/pmac/2-6-5/db/*.template --out-folder .

# softlink to the templates that include basic_asyn_motor_positions
ln -sf basic_asyn_motor_positions.req dls_pmac_asyn_motor_positions.req
ln -sf basic_asyn_motor_settings.req dls_pmac_asyn_motor_settings.req
ln -sf basic_asyn_motor_positions.req dls_pmac_cs_asyn_motor_positions.req
ln -sf basic_asyn_motor_settings.req dls_pmac_cs_asyn_motor_settings.req
