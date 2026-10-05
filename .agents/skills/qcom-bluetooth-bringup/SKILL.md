---
name: qcom-bluetooth-bringup
description: Use for X21-SC162 Bluetooth investigation, especially the OEM/secondary Bluetooth path, pairing, contacts, calls, disconnects and interaction with audio and CP/AA.
---

# X21-SC162 Bluetooth bring-up

This project has evidence of a secondary/OEM Bluetooth path beyond standard Android Bluetooth behavior.

Before carrying a historical or DUDU-beta Bluetooth change forward, classify it as `hardware-oem`, `qualcomm-vendor`, `gsi-compat`, `diagnostic-workaround`, or `unknown` using `.devices/x21-sc162/OLD_PORT_LEDGER.md` and compare `.devices/x21-sc162/DUDU_REFERENCE_MATRIX.md`.

## Best historical control point
r53 is the strongest preserved functional reference for the old OEM Bluetooth path:
- working `sdsdk816`
- PTY/device path `/dev/goc_serial`
- `com.carsyso.bluetooth`
- phone pairing worked
- contacts worked
- call history remained incorrect
- call audio/stability were not fully solved

Do not describe r53 as fully working Bluetooth.

## DUDU references
Keep the references distinct:
- 260812: established working DUDU baseline.
- 260926 C3 beta: static/offline comparison available; runtime BT behavior not yet established.

Static 260926 deltas include:
- SdBluetooth changes from 2.0.8/code 48 to 1.9.5/code 35 with different package content;
- executable code changes in `sdsdk816`;
- ARM64 `libcarsyso_serial_port.so` present in the new SdBluetooth;
- `libSdBTBridge.so` byte-identical between the two DUDU references;
- system Bluetooth APEX changes, with the compared ordinary payload difference concentrated in `Bluetooth.apk` rather than its native libraries.

Do not infer quality or compatibility from the lower SdBluetooth versionCode/versionName. Do not mix the system Bluetooth APEX path with the OEM UART/PTY second-Bluetooth path.

## Call-log protocol clue
Historical analysis around r53/r54 recorded 473 frames shaped as:
`PD + type + UTF-8 name + 0xFF + number`

The selected APK parser expected a different framing model. This is concrete protocol evidence, but not a validated patch recipe.

r54 changed the `SuDingBTModuleSD835` parser and was followed by a CP->AA switching regression. r54b preserved more of the original APK while replacing only `classes.dex`, but the switching problem remained. Therefore:
- parser mismatch is a valid investigation target,
- the r54/r54b APK is not a known-good donor,
- do not attribute the regression solely to APK resources/signing without new evidence.

The 260926 SD835 decoder also changed, but static decompilation did not reliably establish that historical call-log-name or HFP problems were fixed. Runtime protocol evidence is still required.

## Map the implementation
Identify on each relevant DUDU reference and old control point:
- actual package path/version in use, including possible `/data/app` override
- Android Bluetooth service/state
- OEM APKs/services/daemons
- `sdsdk816` and bridge dependencies
- native serial JNI actually loaded
- HCI/transport ownership, if standard HCI is involved
- UART/PTY/device-node ownership including `/dev/goc_serial` where applicable
- init startup events and permissions
- contacts data path
- call-log protocol/parser path
- call-control path
- media/call audio routing ownership
- reconnect/watchdog behavior

## Test matrix
Record independently:
- adapter initialization
- discovery
- pairing/bond persistence
- reconnect after reboot
- contacts sync
- call history sync and decoded frame samples
- outgoing/incoming call control
- media audio
- call downlink
- microphone/uplink
- CP/AA switching before and after any Bluetooth APK/native change
- stability over time

## Transfer rules
- Prefer a demonstrated DUDU A15-compatible dependency set over old A11 backport shims when DUDU already provides the function.
- Treat 260926 as a complete reference, not a newer-parts donor bin.
- A successful pair does not prove call or audio paths.
- A successful contacts sync does not prove the call-log parser.
- Do not transplant the r54 parser patch until the current DUDU/target framing and parser mismatch are demonstrated.
- Do not transplant 260926 SdBluetooth or `sdsdk816` alone until their coupled dependencies and actual runtime loading are mapped.
- Treat changes to OEM Bluetooth APK/native components as possible CP/AA regression risks and test mode switching after each change.