# Basic test IOC startup script to verify IOC can execute

cd "$(TOP)"

dbLoadDatabase "dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)

# start IOC shell
iocInit

