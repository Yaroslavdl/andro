---
name: carlinkit-connectivity
description: Use for X21-SC162 CarPlay/Android Auto integration, OEM connectivity services, secondary Bluetooth, phone contacts/calls, head-unit interaction, and cross-subsystem audio routing.
---

# Carlinkit connectivity bring-up

On this device, CP/AA, OEM/secondary Bluetooth and audio routing may form one integration stack. Do not debug them as unrelated features until dependency mapping proves independence.

## Reference hierarchy
Use both complete DUDU references rather than treating the beta as a donor-file collection:
- `2608121631_2608120956`: established working baseline.
- `2609261951_2609241005`: C3 public beta with both static comparison and validated cold-boot HUR runtime evidence.

Read `.devices/x21-sc162/DUDU_REFERENCE_MATRIX.md` before proposing a beta-derived change.

## Physical topology rule
X21-SC162 is batteryless. In the validated HUR test, the tablet both powers the box and acts as the head unit via Headunit Reloaded. There is no meaningful powered `before connection` state on the box for that topology. Do not design a disconnect/reconnect capture that assumes the X21 remains alive after unplugging power.

## Validated 260926 HUR graph
Cold capture `boot_hur_20261002_161047` confirms the stock USB Android Auto path:

```
sd-reverse wrapper
└─ sdAutoReverse parent
   └─ sdAutoReverse child
      ├─ /dev/usb_accessory
      ├─ AA protocol / TLS / authentication / HUR discovery
      ├─ display capture -> Qualcomm AVC encoder
      ├─ /dev/virtual_input -> touch return
      └─ PTY relationship with MainAiBox

sdsdk816 -> /dev/ttyHS1 + OEM PTYs
Android BT HAL -> /dev/ttyHS0
ght-play -> /dev/snd/pcmC0D4p
```

The reverse child is the directly evidenced executor/orchestrator of this working HUR session in DUDU. MainAiBox is a confirmed control/lifecycle participant. SpeedPlay, `sd_carplay`, SdBluetooth, sdsdk816 and sd_mdnsd are running, but this capture does not isolate whether each is required for the USB HUR path.

Runtime-loaded evidence includes `libSdAutoReverse.so`, `libCoreUtils.so`, tinyalsa, SpeedPlay CarPlay/AA/AirPlay libraries, Qualcomm `audio.primary.lito.so`/ACDB libraries, and ARM64 Carsyso serial JNI. Do not equate a loaded multipurpose library with an active feature.

## Port-contract rule
For a new Lineage port, distinguish the demonstrated contract from DUDU's chosen implementation. Strong contracts from the working session are:
- USB gadget/accessory/AOA lifecycle;
- `/dev/usb_accessory` access or equivalent transport contract;
- display capture/media path;
- Qualcomm AVC encoder compatibility;
- `/dev/virtual_input` or equivalent touch return;
- legacy Qualcomm vendor/VNDK30 compatibility;
- correct ABI support for retained OEM components.

Do not automatically require the exact DUDU APK/process set if another implementation can satisfy the same contract.

## Audio caution
The working HUR video/touch session was observed with `AFE_LOOPBACK_TX Port=None`. `ght-play` continuously owned `pcmC0D4p` at S16_LE/stereo/48 kHz both in the reference baseline and cold/HUR snapshots. Its audible/projection role is unresolved.

Therefore:
- do not treat r88/r88f fixed RX loopback routing as a baseline projection requirement;
- do not write mixer controls before a use-case-specific route transition is measured;
- isolate local playback, projection media, call audio and microphone as separate experiments.

## Known historical evidence
Previous Lineage builds achieved CP/AA image/touch, OEM phone pairing and contact retrieval. Remaining issues included call audio, call history, periodic Bluetooth disconnects and later audio regressions.

## Dependency-map workflow
For each operation (cold HUR start, local playback, phone pairing, contacts, call, route change):
1. Capture process/service changes.
2. Capture targeted logcat and kernel events.
3. Identify OEM APK/service/daemon involved.
4. Identify binder/socket/device-node/sysfs interfaces used.
5. Identify native libraries actually loaded.
6. Identify Bluetooth stack/profile participation.
7. Identify AudioPolicy/AudioFlinger/PCM/mixer state.
8. Compare 260812, 260926 and the nearest useful old-Lineage control point.
9. Classify each proposed transfer as `hardware-oem`, `qualcomm-vendor`, `gsi-compat`, `diagnostic-workaround`, or `unknown`.

## Separate planes
Track separately:
- projection transport/control;
- video/display;
- touch/input return;
- Bluetooth pairing/control;
- contacts/data;
- telephony/call control;
- media audio;
- call audio;
- microphone.

Success in one plane is not proof another is configured correctly.

## Regression-first and transfer rules
If an old Lineage build had working CP/AA, pairing, contacts or audio, recover the exact known-good-to-regressed delta before introducing a new stock-derived modification.

A 260926 component is eligible for a port experiment only after the target failure is reproduced, its runtime dependency chain is mapped, its relevant delta from 260812 is understood, and runtime evidence indicates participation in the desired behavior.