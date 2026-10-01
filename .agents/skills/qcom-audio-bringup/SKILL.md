---
name: qcom-audio-bringup
description: Use for X21-SC162/SM6350 audio and microphone bring-up, especially Qualcomm Audio HAL, policy, mixer paths, CP/AA routing, Bluetooth call/media routing and regressions.
---

# X21-SC162 Qualcomm audio bring-up

## Principle
Audio is a routing and lifecycle problem as well as a HAL problem. Separate local/media playback, CP/AA media, Bluetooth media, call downlink and microphone/uplink.

Before transferring a historical audio fix, classify it as `hardware-oem`, `qualcomm-vendor`, `gsi-compat`, `diagnostic-workaround`, or `unknown` using `.devices/x21-sc162/OLD_PORT_LEDGER.md`.

Use `.devices/x21-sc162/DUDU_REFERENCE_MATRIX.md` when comparing the August baseline to the September C3 beta.

## Historical constraints
- r58 demonstrated ordinary audio in the old port while an audio controller configured AFE loopback and `RX_CDC_DMA_RX_0`. This is a historical working state, not proof of a hardware constant.
- r74 established that PHH could hide `/vendor/etc/audio` behind an empty mount. Restoring policy visibility removed a prior output-open failure. Treat that failure as GSI compatibility unless the same mount/missing-policy condition is demonstrated again.
- r74/r77 `r69_audio_control.sh` was a workable initializer but tolerated individual `tinymix` failures and is technical debt, not a reference implementation.
- r88 restored sound by removing the r87 preready/control experiment and rolling back to the older controller.
- r88f statically changed `AFE_LOOPBACK_TX Port` from `None` to `RX_CDC_DMA_RX_0`; later observations showed routes changing dynamically during playback.
- r88g still had intermittent audio trouble. PCM read errors were observed; compressed-offload causality was not established.

## DUDU 260926 static constraints
The C3 beta does not show a replacement primary Audio HAL or policy set in the static comparison:
- compared `audio.primary.lito.so` binaries are unchanged;
- compared audio policy XML is unchanged;
- `loopback1.sh` is unchanged.

The concrete configuration change is in `/vendor/etc/mixer_paths_lagoonqrd.xml` for named HDMI-input routes:
- `AFE_LOOPBACK_TX Port`: `TERT_MI2S_RX` -> `PRI_MI2S_TX`;
- explicit PRIM/TERT MI2S channel configuration;
- route-specific 48/44.1 kHz controls.

This is evidence of a coordinated route correction, not evidence that `PRI_MI2S_TX` is correct for all playback, CP/AA, HFP or microphone use cases. It also does not validate the old r88f `RX_CDC_DMA_RX_0` experiment.

## Collect from working DUDU
- exact build/reference version
- audio-related services/processes
- audio HAL/service registration
- audio policy configuration
- mixer paths and platform/audio configs
- relevant properties
- `dumpsys audio`
- `dumpsys media.audio_flinger`
- `dumpsys media.audio_policy`
- logs while starting/stopping each audio use case
- passive mixer/route snapshots over lifecycle
- OEM reverse/loopback services that may own routing

## For every failure
1. Name the exact use case.
2. Reproduce it and capture framework/HAL/vendor evidence.
3. Confirm framework sees the expected output/input device.
4. Confirm policy chooses the expected route and that policy files are actually visible.
5. Confirm Audio HAL accepts the route.
6. Observe mixer/control transitions over start, playback, pause and stop; do not judge one snapshot as a constant.
7. Compare the same use case against the appropriate DUDU reference; do not mix static beta evidence with runtime claims.
8. Check OEM daemon/service ownership.
9. Check device nodes/kernel driver errors after userspace routing/lifecycle is understood.
10. Classify any proposed historical or beta-derived fix before transfer.

## Prohibited shortcuts
Do not:
- force `RX_CDC_DMA_RX_0` merely because r58/r88f used it,
- force `PRI_MI2S_TX` globally merely because 260926 uses it in named HDMI-input mixer paths,
- recreate the PHH `/vendor/etc/audio` workaround unless the same PHH condition exists,
- treat route switching as failure without correlated errors,
- infer call-audio correctness from ordinary media playback,
- call compressed offload the root cause without new evidence,
- claim the 260926 audio change fixed a symptom until runtime testing demonstrates it.

## Regression analysis
For an old-port regression, compare the nearest known-good and failing control points first. r74/r77 and r88 are particularly useful for distinguishing GSI policy/lifecycle problems from vendor/hardware behavior. For DUDU, keep 260812 as the established baseline and 260926 as a separate reference until its runtime baseline is collected.