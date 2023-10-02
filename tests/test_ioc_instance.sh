#!/bin/bash

set -xe

THIS_DIR=$(dirname ${0})
cd ${THIS_DIR}/ioc_instance

if ! ibek --version; then
    pip install ibek
fi

tmpdir=$(mktemp -d)

ibek startup generate ioc.yaml ../../*/*.support.yaml --out ${tmpdir}/st.cmd \
    --db-out ${tmpdir}/ioc.db

if not diff ${tmpdir}/st.cmd ./st.cmd || not diff ${tmpdir}/ioc.db ./ioc.db; then
    echo "ERROR: Generated files st.cmd / db.subst differ from expected"
    exit 1
fi

rm -r ${tmpdir}

