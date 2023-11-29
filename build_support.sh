#!/bin/bash

# This script is used to generate support YAML for ibek from the latest
# released versions of builder support modules at DLS
# as of 07/11/2023

# assumes ibek is a peer to this folder's parent (as ibek-support is usually
# a submodule of an ioc-xxxx) Adjust Path if this is not the case.

echo '
WARNING This file does not add pvi: entries yet and these will get deleted
so dont run it!
'
exit 1

set -xe

cd $(realpath $(dirname $0))
PATH=$PATH:$(realpath ../../ibek)

# overrides coerce NELEMENTS to int
builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/ADCore/3-12-1dls3 ADCore/ADCore.ibek.support.yaml -o '193:10 178:10'

builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/ADAravis/2-2-1dls16/ ADAravis/ADAravis.ibek.support.yaml
# fixup ADAravis template path to parameterised by CLASS and repair comment in startup script
sed -i ADAravis/ADAravis.ibek.support.yaml -e 's`db/AVT_Mako_1_52.template`db/{{CLASS}}.template`' -e 's/aravisConfig(const/# aravisConfig(const/'
# remove the PV_ALIAS argument
sed -i -r '71,78d' ADAravis/ADAravis.ibek.support.yaml

# still verifying the remaining modules - so don't auto generate from builder
exit 0

builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/zebra/2-9-2 zebra/zebra.ibek.support.yaml


builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/motor/7-0dls9-1 motor/motor.ibek.support.yaml
builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/pmac/2-5-23beta1/ pmac/pmac.ibek.support.yaml  -o '14:A+B 474:A+B 801:1 805:1.0 804:1.0'

builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/asyn/4-41dls2 asyn/asyn.ibek.support.yaml
builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/calc/3-7-3/ calc/calc.ibek.support.yaml
builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/busy/1-7-2dls6 busy/busy.ibek.support.yaml
builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/devIocStats/3-1-14dls3-3/ iocStats/iocStats.ibek.support.yaml

# these modules upstream are very different to upstream - so don't generate from builder
# builder2ibek.support.py /dls_sw/prod/R3.14.12.7/support/autosave/5-9dls2/ autosave/autosave.ibek.support.yaml
