---
name: qcom-audio-bringup
description: Use for X21-SC162/SM6350 audio and microphone bring-up, especially Qualcomm Audio HAL, policy, mixer paths, CP/AA routing, Bluetooth call/media routing and regressions.
---

# X21-SC162 Qualcomm audio bring-up

## Principle
Audio is a routing problem as well as a HAL problem. Separate media playback, projection audio, Bluetooth media, call audio and microphone capture.

## Collect from working DUDU
- audio-related services/processes
- audio HAL/service registration
- audio policy configuration
- mixer paths and platform/audio configs
- relevant properties
- `dumpsys audio`
- `dumpsys media.audio_flinger`
- `dumpsys media.audio_policy`
- logs while starting/stopping each audio use case

## For every failure
1. Name the use case: media, CP/AA, Bluetooth media, call downlink, call uplink/mic.
2. Confirm framework sees the expected output/input device.
3. Confirm policy chooses the expected route.
4. Confirm Audio HAL accepts the route.
5. Compare mixer/control changes against DUDU.
6. Check OEM daemon involvement.
7. Check device nodes/kernel driver errors only after userspace routing is understood.

## Regression analysis
Because ordinary audio worked in some previous Lineage builds and regressed later, find the last known-good build and diff:
- vendor files/blobs
- audio configs
- properties
- init services
- overlays
- SELinux
- framework patches

Do not solve call-audio failure by assuming general playback audio is also broken.