# EXAMPLE IOC Instance to demonstrate the ADSimDetector Generic IOC

cd "$(TOP)"

dbLoadDatabase "dbd/ioc.dbd"
ioc_registerRecordDeviceDriver(pdbbase)

# simDetectorConfig(portName, maxSizeX, maxSizeY, dataType, maxBuffers, maxMemory)
simDetectorConfig("EXAMPLE.CAM", 2560, 2160, 1, 50, 0)

# NDPvaConfigure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr, pvName, maxMemory, priority, stackSize)
NDPvaConfigure("EXAMPLE.PVA", 2, 0, "EXAMPLE.CAM", 0, "EXAMPLE:IMAGE", 0, 0, 0)

# NDFileHDF5Configure(portName, queueSize, blockingCallbacks, NDArrayPort, NDArrayAddr)
NDFileHDF5Configure("EXAMPLE.HDF", 2, 0, "EXAMPLE.CAM", 0)

startPVAServer

# instantiate Database records for Sim Detector
dbLoadRecords (simDetector.template, "P=EXAMPLE, R=:CAM:, PORT=EXAMPLE.CAM, TIMEOUT=1, ADDR=0")
dbLoadRecords (NDPva.template, "P=EXAMPLE, R=:PVA:, PORT=EXAMPLE.PVA, ADDR=0, TIMEOUT=1, NDARRAY_PORT=EXAMPLE.CAM, NDARRAY_ADR=0, ENABLED=1")
dbLoadRecords (NDFileHDF5.template, "P=EXAMPLE, R=:HDF:, PORT=EXAMPLE.HDF, ADDR=0, TIMEOUT=1, XMLSIZE=2048, NDARRAY_PORT=EXAMPLE.CAM, NDARRAY_ADDR=0, ENABLED=1, SCANRATE=I/O Intr")

# also make Database records for DEVIOCSTATS
dbLoadRecords(iocAdminSoft.db, "IOC=EXAMPLE")
dbLoadRecords(iocAdminScanMon.db, "IOC=EXAMPLE")

# start IOC shell
iocInit

# poke some records
dbpf "EXAMPLE:CAM:AcquirePeriod", "0.1"
