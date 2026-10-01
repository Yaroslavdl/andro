---
name: qcom-bluetooth-bringup
description: Use for X21-SC162 Bluetooth investigation, especially the OEM/secondary Bluetooth path, pairing, contacts, calls, disconnects and interaction with audio and CP/AA.
---

# X21-SC162 Bluetooth bring-up

This project has evidence of a secondary/OEM Bluetooth path beyond a simplistic assumption of standard Android Bluetooth behavior.

## Historical baseline
In successful previous Lineage builds:
- phone pairing worked
- contacts could be retrieved
- call audio remained problematic
- call history remained problematic
- periodic disconnects occurred

Treat each capability as a separate test.

## Map the implementation
Identify on DUDU and old Lineage:
- Android Bluetooth service/state
- OEM APKs/services/daemons participating
- HCI/transport ownership
- serial/USB/UART/device-node interfaces if any
- config files and properties
- profile/data path for contacts
- call-control path
- audio routing path
- watchdog/reconnect behavior

## Test matrix
Record independently:
- adapter initialization
- discovery
- pairing/bond persistence
- reconnect after reboot
- contacts sync
- call history sync
- outgoing call control
- incoming call control
- media audio
- call downlink
- microphone/uplink
- stability over time

## Debug rule
A successful pair does not prove the call path is correct. A successful contacts sync does not prove standard Android profile ownership. Trace the OEM implementation before replacing components with generic Bluetooth assumptions.