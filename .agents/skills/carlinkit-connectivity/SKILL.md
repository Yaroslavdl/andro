---
name: carlinkit-connectivity
description: Use for X21-SC162 CarPlay/Android Auto integration, OEM connectivity services, secondary Bluetooth, phone contacts/calls, head-unit interaction, and cross-subsystem audio routing.
---

# Carlinkit connectivity bring-up

On this device, CP/AA, OEM/secondary Bluetooth and audio routing may form one integration stack. Do not debug them as unrelated features until dependency mapping proves independence.

## Reference hierarchy
Use both complete DUDU references rather than treating the beta as a donor-file collection:
- `2608121631_2608120956`: established working baseline.
- `2609261951_2609241005`: C3 public beta, currently supported by static/offline comparison; runtime behavior is not yet established.

Read `.devices/x21-sc162/DUDU_REFERENCE_MATRIX.md` before proposing a beta-derived change.

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

## 260926 static evidence
Compared shell scripts, init rc, VINTF, fstab and SELinux policy did not introduce a new reverse startup mechanism. Instead, executable/native changes are concentrated in the coordinated projection stack:
- `sdAutoReverse`
- `sdCarplaySvc`
- `sdCarplaySvc_wire`
- reverse/bridge/CarPlay/AirPlay/CoreUtils libraries
- new `sd_mdnsd_wire`
- additions under `/system/sd/lib`
- changed SdMirror native packaging
- MainAiBox DEX changes including top-window/display tracking behavior

Therefore, do not copy a single beta APK or library into Lineage and call it a mirroring/CP fix. First map the whole dependency set actually used at runtime.

## Dependency-map workflow
For each operation (connect phone, start CP/AA, switch mode, mirror, sync contacts, place call, route media):
1. Capture process/service changes.
2. Capture targeted logcat and kernel events.
3. Identify OEM APK/service/daemon involved.
4. Identify binder/socket/device-node/sysfs interfaces used.
5. Identify native libraries actually loaded.
6. Identify Bluetooth stack/profile participation.
7. Identify audio policy/device/routing changes.
8. Compare 260812, 260926 and the nearest useful old-Lineage control point.

## Separate planes
Track these separately even if one OEM service coordinates them:
- projection transport/control plane
- video/display/mirroring plane
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

## Beta transfer rule
A 260926 component is eligible for a port experiment only after:
1. the target failure is reproduced,
2. the component's dependency chain is mapped,
3. its relevant delta from 260812 is understood,
4. runtime evidence indicates that the changed component participates in the desired behavior.