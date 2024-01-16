# Modbus Support Configuration

The current Modbus support is primarily focused on creating Input/Output Controllers (IOCs) that interact with Modbus TCP instrumentation. Presently, the **ibek support** is limited to reading 32-bit integers and floating-point registers.

This support has undergone testing with *plc M340* and *electrex*.

## Examples

Below an extract of a working *ioc.yaml* configurationto read various variables.

```yaml
ioc_name: dt-lnf-ioc
description: Modbus PLC/sensors Technical Division 

entities:

- type: modbus.modbusPortConfigure
  ASYNPORT: DTPLC-PLC
  IP: 192.168.146.22
 
- type: modbus.modbusAsynConfigure
  MODBUSPORT: DTPLC
  ASYNPORT: DTPLC-PLC
  FUNC_CODE: 4
  STARTADDR: 1588
  DATA_LENGTH: 120
  DATA_TYPE: 7

- type: modbus.modbusPortConfigure
  ASYNPORT: ELECTREX-PLC
  IP: 192.168.146.107
 
- type: modbus.modbusAsynConfigure
  MODBUSPORT: ELECTREX1
  ASYNPORT: ELECTREX-PLC
  SERVER_ADDR: 1
  FUNC_CODE: 4
  STARTADDR: 277
  DATA_LENGTH: 8
  POLL_DELAY: 5000
  DATA_TYPE: 7

- type: modbus.modbusAsynConfigure
  MODBUSPORT: ELECTREX12
  ASYNPORT: ELECTREX-PLC
  SERVER_ADDR: 1
  FUNC_CODE: 4
  STARTADDR: 413
  DATA_LENGTH: 8
  POLL_DELAY: 5000
  DATA_TYPE: 7

- type: modbus.modbusFloatReadout
  PORT: DTPLC
  P: DT
  R: ":cab2:ac_ea"
  OFFSET: 0
  DESC: "Instantaneous Power"
  EGU: "KW"

- type: modbus.modbusFloatReadout
  PORT: DTPLC
  P: DT
  R: ":cab2:ac_p"
  OFFSET: 14
  DESC: "Average Power"
  EGU: "KW"

- type: modbus.modbusFloatReadout
  PORT: ELECTREX1
  P: DT
  R: ":kilo:ced_nd_p"
  OFFSET: 0
  DESC: "Instantaneous Power"
  EGU: "KW"

- type: modbus.modbusFloatReadout
  PORT: ELECTREX12
  P: DT
  R: ":kilo:ced_nd_ea"
  OFFSET: 0
  DESC: "Average Power"
  EGU: "KW"
