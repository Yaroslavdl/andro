---
name: hardware-bringup
description: Coordinate end-to-end bring-up of Android hardware subsystems such as camera, audio, Wi-Fi, Bluetooth, sensors, biometrics, display, GNSS, NFC, USB and telephony by tracing framework-to-kernel dependencies and comparing stock with LineageOS.
---

# Hardware Bring-up Coordinator

Use this skill when a feature is broadly 'not working' and the failing layer is not yet known.

## Trace the stack
Framework/app -> system service -> binder interface -> HAL -> vendor libraries/config -> device nodes/sysfs -> kernel driver/module -> firmware/hardware.

## Procedure
1. Define a reproducible test and expected stock behavior.
2. Collect focused logs while triggering the feature.
3. Identify the first component that fails or disappears.
4. Delegate mentally to the appropriate workflow: stock ROM analysis, stock-lineage diff, HAL/VINTF, blobs, SELinux, kernel or boot.
5. Compare stock at the same layer before modifying Lineage.
6. Track dependencies across layers; a framework symptom often originates below it.
7. Make one causally motivated change at a time when practical.
8. Verify not only that the UI works, but that the underlying service/HAL is stable across reboot and repeated use.

## Subsystem checklist
For camera/audio/connectivity/sensors/biometrics/display/GNSS/NFC/USB/telephony consider: feature/permission XML, overlays, properties, init, VINTF, HAL instance, proprietary libraries, configuration files, firmware, SELinux, device nodes, modules and DT.

Avoid cargo-culting another device tree unless SoC/vendor generation and the specific integration path are demonstrably equivalent.