# DUDU reference matrix: 260812 -> 260926 beta

This document records the static comparison between:
- baseline: `2608121631_2608120956`
- public beta: `2609261951_2609241005` / DUDUAUTO C3

Source analysis date: 2026-10-01. The beta was analyzed offline; runtime behavior was not measured in this comparison.

## High-level conclusion
The September beta is a meaningful update to OEM applications, the CP/AA/mirroring native stack and parts of Android framework, but it is not a platform-generation change.

Unchanged generation baseline:
- system/system_ext/product: Android 15 / SDK 35
- vendor/ODM: Android 11 / SDK 30
- Android build ID: AQ3A.241126.002
- system security patch: 2024-09-05
- vendor security patch: 2021-04-05
- kernel version: 4.19.157-perf
- boot header: v2 / 4096

The static analysis found no changes in compared shell startup scripts, init rc, VINTF, fstab or SELinux policy. Important behavioral changes are concentrated in APK/DEX and native binaries/libraries.

## Matrix

| Area | 260812 baseline | 260926 beta | Old Lineage control point | Porting interpretation |
| --- | --- | --- | --- | --- |
| Platform generation | A15 system + A11 vendor/ODM + 4.19 kernel | same | Lineage 18.1/GSI on same legacy vendor generation | Confirms the mixed-generation architecture remains intentional |
| CP/AA shell/init path | baseline `sd-reverse.sh`/related rc | compared scripts/rc unchanged | r34-r35 restored stock-style mode lifecycle | Do not invent a new shell lifecycle from the beta; investigate changed native/OEM code |
| CP/AA native stack | baseline | `.text` changed in `sdAutoReverse`, `sdCarplaySvc`, `sdCarplaySvc_wire`; reverse libraries changed; `sd_mdnsd_wire` and `/system/sd/lib` additions | historical OEM donor/integration work | Treat OEM APK + native reverse stack as a coordinated set, not isolated donor files |
| Mirroring | older SdMirror/native set | SdMirror gets ARM64 libraries; some ARM32 libraries removed; native reverse stack updated | old CP/AA/display/touch fixes | Strong static change area; runtime improvement still unverified |
| MainAiBox | xq_1.0.35 | same version string, 10 DEX entries changed; top-window/display tracking code changed | r30-r35/r56 OEM lifecycle/touch/display history | Compare behavior and dependencies, not versionName alone |
| Audio HAL | `audio.primary.lito.so` baseline | compared audio HAL binaries unchanged | old vendor audio | No evidence of a new primary Audio HAL implementation |
| Audio policy XML | baseline | compared policy XML unchanged | r74 PHH hid `/vendor/etc/audio` | r74 remains a GSI visibility issue, not a beta-equivalent vendor fix |
| Mixer routes | baseline `mixer_paths_lagoonqrd.xml` | HDMI-input paths changed: `AFE_LOOPBACK_TX Port` TERT_MI2S_RX -> PRI_MI2S_TX plus channel/rate controls | r58/r88f experimented with RX_CDC_DMA_RX_0 | Beta change is route-specific; never generalize it to all playback or CP/AA without runtime evidence |
| `loopback1.sh` | present | unchanged | historical audio controller experiments | Do not remove/replace until route ownership is measured |
| OEM Bluetooth APK | SdBluetooth 2.0.8 code 48 | SdBluetooth 1.9.5 code 35, different content | r53 pairing/contacts; r54 parser experiment | Version number decreased; do not rank versions by number. Compare protocol/runtime behavior |
| OEM BT native daemon | old `sdsdk816` | executable code changed | r53 working transport/contacts | Strong candidate for DUDU-vs-r53 dependency comparison |
| BT bridge | `libSdBTBridge.so` | byte-identical | r53 bridge path | Suggests not every OEM BT layer changed |
| serial JNI | prior package content | ARM64 `libcarsyso_serial_port.so` present in new SdBluetooth | old port restored serial JNI/native pieces | Important architecture clue; verify actual runtime load before transfer decisions |
| System Bluetooth | older Bluetooth APEX APK | APEX payload differs only in `Bluetooth.apk` among compared ordinary files | separate from OEM UART/PTY path | Keep system Bluetooth and OEM second-BT analysis separate |
| Wi-Fi kernel module | `qca_cld3_wlan.ko` | `.text` identical; `.data` and build-id differ | r31 restored `second_wifi.sh` + module load | No evidence that beta replaces the historical need for correct OEM/vendor initialization |
| Other vendor modules | baseline | 36/37 compared changed-hash modules have identical parsed ELF sections | old vendor/kernel stack | Do not call this a broad driver-code update |
| Adreno vendor libs | baseline | EGL/GLES/Vulkan vendor libraries identical | display stack | No static evidence of an Adreno driver update |
| MediaScanner | V4 | V5 | old high-load concerns | Static code comparison does not establish that historical scanning load is fixed |
| `vendor.cnss_diag` | existing | binary/args/init trigger unchanged | r88g optimization candidate | Still only a measurement candidate; not a bring-up fix |
| Wi-Fi ADB | init behavior present | unchanged | r56 network ADB | Development/security concern remains; not evidence for hardware support |
| LED scripts | baseline | unchanged | r32 LED working | No beta-specific LED conclusion |

## CP/AA and mirroring details
Compared shell scripts and init/VINTF/fstab/SELinux did not introduce a new reverse startup mechanism. The meaningful delta is inside the coordinated OEM/native stack:
- `sdAutoReverse`
- `sdCarplaySvc`
- `sdCarplaySvc_wire`
- `libSdAutoReverse.so`
- `libSdBridge.so`
- `libSdCarplay.so`
- `libAirPlay.so`
- `libCoreUtils.so`
- new `sd_mdnsd_wire`
- additions under `/system/sd/lib`
- changed SdMirror architecture/library packaging

Porting rule: do not copy one APK or `.so` from 260926 into another userspace and assume compatibility. Map its exact dependencies, signatures, services, ABI and native library set first.

## Audio details
The most concrete configuration delta is `/vendor/etc/mixer_paths_lagoonqrd.xml` for four named HDMI-input routes. The beta changes `AFE_LOOPBACK_TX Port` from `TERT_MI2S_RX` to `PRI_MI2S_TX` and explicitly configures PRIM/TERT MI2S channels/rates.

This does not establish `PRI_MI2S_TX` as the correct global route and does not validate the old r88f `RX_CDC_DMA_RX_0` experiment. Runtime route observation is required for each use case.

## Bluetooth details
Static evidence shows coordinated but partial change:
- SdBluetooth package content/version changed;
- `sdsdk816` executable code changed;
- ARM64 `libcarsyso_serial_port.so` is present in the new SdBluetooth;
- `libSdBTBridge.so` is unchanged;
- system Bluetooth APEX also changes, but it must remain analytically separate from the OEM UART/PTY second-Bluetooth stack.

The decompiled SD835 decoder changed, but static decompilation did not prove that historical call-log naming or HFP issues are fixed. r53 remains the best old functional control point; r54 remains an unvalidated parser experiment with a CP->AA regression.

## Kernel/driver interpretation
All ten OTA image hashes changed, but that does not imply all executable components changed. The boot ramdisk content/mode/uid/gid comparison found all 15 entries equivalent. Among 37 vendor `.ko` files with changed full hashes, 36 had identical parsed ELF sections; `qca_cld3_wlan.ko` retained identical `.text` while `.data` and build-id changed.

Therefore, do not describe 260926 as a broad kernel/Wi-Fi driver rewrite without stronger semantic evidence.

## Runtime questions for 260926
When the beta is installed and a passive baseline can be collected, verify before modifying anything:
1. actual package path/version used for SdBluetooth, MainAiBox and MediaScanner, including possible `/data/app` overrides;
2. boot/service errors and restart loops;
3. CP/AA and mirroring behavior;
4. current audio route transitions for the failing/interesting use case without forcing mixer controls;
5. OEM BT pairing, contacts, call history, call audio and reconnect behavior separately;
6. CPU/I/O/temperature after boot and media scan;
7. load from `vendor.cnss_diag`, MediaProvider and `carnetos.usbmedia`.

## Transfer rule
The September beta is a second complete reference, not a bag of newer donor files. A component becomes a porting candidate only after its current dependency chain and the target failure are both demonstrated.