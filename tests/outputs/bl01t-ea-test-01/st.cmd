# EPICS IOC Startup Script generated by https://github.com/epics-containers/ibek

cd "/epics/ioc"

epicsEnvSet EPICS_TZ GMT0BST

dbLoadDatabase dbd/ioc.dbd
ioc_registerRecordDeviceDriver pdbbase

dbLoadRecords("/epics/ioc/config/ioc.db")

dbLoadRecords /ioc.db
iocInit


dbpf "bl01t:IBEK:A" "2.54"
dbpf "bl01t:IBEK:B" "2.61"
dbgf bl01t:IBEK:SUM

