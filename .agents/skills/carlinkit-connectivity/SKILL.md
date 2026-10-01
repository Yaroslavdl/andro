---
name: carlinkit-connectivity
description: Use for X21-SC162 CarPlay/Android Auto integration, OEM connectivity services, secondary Bluetooth, phone contacts/calls, head-unit interaction, and cross-subsystem audio routing.
---

# Carlinkit connectivity bring-up

On this device, CP/AA, OEM/secondary Bluetooth and audio routing may form one integration stack. Do not debug them as unrelated features until dependency mapping proves independence.

## Known historical evidence
Previous Lineage builds achieved:
- CP/AA image output and touch
- phone pairing through the secondary/OEM Bluetooth path
- contact retrieval

Remaining/observed issues included:
- call audio
- call history
- periodic Bluetooth disconnects
- later audio regressions

## Dependency-map workflow
For each operation (connect phone, start CP/AA, sync contacts, place call, route media):
1. Capture process/service changes.
2. Capture targeted logcat and kernel events.
3. Identify OEM APK/service/daemon involved.
4. Identify binder/socket/device-node/sysfs interfaces used.
5. Identify Bluetooth stack/profile participation.
6. Identify audio policy/device/routing changes.
7. Compare DUDU to the last known-good Lineage build.

## Separate planes
Track these separately even if one OEM service coordinates them:
- projection transport/control plane
- video/display plane
- touch/input return path
- Bluetooth pairing/control plane
- contacts/PBAP-like data path
- telephony/call-control path
- media audio path
- call audio path
- microphone capture path

A success in one plane is not proof another is configured correctly.

## Regression-first rule
If an old Lineage build had working CP/AA, pairing, contacts or audio, first recover the exact differences between the known-good and regressed build before introducing a new stock-derived modification.