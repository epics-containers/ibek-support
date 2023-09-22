#!/bin/bash

set -xe

tmpdir=$(mktemp -d)

# TODO - we should really be sending ibek IOC YAML here instead of
# a hand coded startup script - baby steps ...
echo '
cd "$(TOP)"

dbLoadDatabase "dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)
simDetectorConfig("TEST.CAM", 2560, 2160, 1, 50, 0)

dbLoadRecords (simDetector.template, "P=TEST, R=:CAM:, PORT=TEST.CAM, TIMEOUT=1, ADDR=0")

iocInit
' > ${tmpdir}/st.cmd

$docker cp ${tmpdir}/st.cmd test_me:/epics/ioc/config/st.cmd
$docker exec -dit test_me bash -c "cd /epics/ioc; ./start.sh"

# verify that the IOC is running
$docker exec test_me caget TEST:CAM:Acquire
# now try and run the simdetector and verify that it delivers some frames
$docker exec test_me caput TEST:CAM:Acquire 1

first=$($docker exec test_me caget TEST:CAM:ArrayCounter_RBV)
second=$($docker exec test_me caget TEST:CAM:ArrayCounter_RBV)
if [[ $first == 0 || $first == $second ]] ; then
    echo "ERROR: simdetector did not deliver any frames"
    exit 1
fi


