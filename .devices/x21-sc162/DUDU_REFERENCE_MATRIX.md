# DUDU reference matrix: 260812 -> 260926 beta

This document records the static comparison between:
- baseline: `2608121631_2608120956`
- public beta: `2609261951_2609241005` / DUDUAUTO C3

Source static analysis date: 2026-10-01. Runtime evidence for 260926 was later collected on 2026-10-02 using a cold power-on -> automatic HUR projection capture.

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

## Validated 260926 HUR runtime reference
Reference capture: `06_live_logs/boot_hur/boot_hur_20261002_161047`.

Physical topology: the batteryless X21 is powered by the tablet, and that same tablet runs Headunit Reloaded as the head unit. A phone is not part of this test.

Confirmed working stock path:

```
sd-reverse wrapper
└─ sdAutoReverse parent
   └─ sdAutoReverse child
      ├─ /dev/usb_accessory
      ├─ AA protocol + TLS/auth + HUR discovery
      ├─ screen capture / media path -> Qualcomm AVC encoder
      ├─ /dev/virtual_input -> touch return
      └─ PTY control relationship with MainAiBox

sdsdk816
└─ child -> /dev/ttyHS1 + OEM PTY endpoints

ght-play -> /dev/snd/pcmC0D4p
```

All collector snapshots were taken after the HUR session was already established; boot logs provide the transition evidence. The session shows AOA switch, successful TLS/auth, explicit HUR identification, channel setup, video start, Qualcomm AVC encoder initialization, frame production and touch events.

Runtime dependency evidence:
- `sdAutoReverse`: `libSdAutoReverse.so`, `libCoreUtils.so`, `libtinyalsa.so` loaded.
- SpeedPlay: `libSdCarplay.so`, `libSdAuto.so`, `libSdMirrorSwitchAoa.so`, `libsd_wapm.so`, AirPlay libraries and `libCoreUtils.so` loaded. Loading does not prove each feature/path is active.
- Audio HAL: `audio.primary.lito.so`, ACDB libraries and VNDK30 tinyalsa loaded.
- MainAiBox and SdBluetooth load ARM64 `libcarsyso_serial_port.so`.
- `ght-play` loads lib64 tinyalsa and holds `pcmC0D4p` running S16_LE/stereo/48 kHz.

Important negative/limiting evidence:
- `sdCarplaySvc`, `sdCarplaySvc_wire`, `sd_mdnsd_wire` and SdMirror were not observed as separate processes in this capture. Static presence/version strings are not executable evidence.
- No new named `.so` mapping appeared between collector snapshots; the session was already active before the first snapshot.
- The reference idle baseline was not projection-off: it already had the reverse stack and ght-play active.
- Working HUR video/touch occurred with `AFE_LOOPBACK_TX Port=None`; this weakens any claim that the old r88/r88f fixed RX loopback route is a baseline projection requirement.
- The audible role of `ght-play` is still unknown.
- SELinux was permissive; future enforcing behavior is not established.

## Matrix

| Area | 260812 baseline | 260926 beta | Old Lineage control point | Porting interpretation |
| --- | --- | --- | --- | --- |
| Platform generation | A15 system + A11 vendor/ODM + 4.19 kernel | same | Lineage 18.1/GSI on same legacy vendor generation | Confirms the mixed-generation architecture remains intentional |
| CP/AA shell/init path | baseline `sd-reverse.sh`/related rc | compared scripts/rc unchanged | r34-r35 restored stock-style mode lifecycle | Do not invent a new shell lifecycle from the beta; investigate changed native/OEM code |
| CP/AA runtime | not re-measured here | HUR USB/AOA + AA/TLS/auth + video + touch confirmed | historical working CP/AA | Preserve demonstrated transport/video/input contracts; do not assume every stock OEM component is independently mandatory |
| CP/AA native stack | baseline | `.text` changed in `sdAutoReverse`, `sdCarplaySvc`, `sdCarplaySvc_wire`; reverse libraries changed; `sd_mdnsd_wire` and `/system/sd/lib` additions | historical OEM donor/integration work | Runtime identifies `sdAutoReverse` child as the directly evidenced HUR executor; static companions still require necessity isolation |
| Mirroring | older SdMirror/native set | SdMirror gets ARM64 libraries; some ARM32 libraries removed; native reverse stack updated | old CP/AA/display/touch fixes | Static change area; HUR AA test does not prove separate mirroring behavior |
| MainAiBox | xq_1.0.35 | same version string, DEX changes | r30-r35/r56 lifecycle/touch/display history | Runtime confirms MainAiBox and PTY participation, not that its whole implementation must be copied |
| Video encoder | legacy Qualcomm media stack | working HUR initializes `OMX.qcom.video.encoder.avc` | old display/projection path | Qualcomm AVC/media compatibility is a strong port contract |
| Touch return | stock reverse path | `/dev/virtual_input` opened by reverse child; real touch events observed | previous physical touch worked | Kernel/device-node/input contract is a strong bring-up requirement |
| Audio HAL | `audio.primary.lito.so` baseline | compared binary unchanged; runtime-loaded | old vendor audio | Preserve legacy vendor/VNDK30 audio compatibility |
| Audio policy XML | baseline | unchanged and runtime-used | r74 PHH hid `/vendor/etc/audio` | r74 remains a GSI visibility workaround, not a stock audio implementation requirement |
| Mixer routes | baseline | HDMI-input static route changes | r58/r88f experimented with RX_CDC_DMA_RX_0 | Working HUR video/touch has `AFE_LOOPBACK_TX Port=None`; do not generalize old fixed-loopback route |
| `ght-play` | present | persistent direct PCM runtime confirmed | historical audio experiments | Role unresolved; isolate with controlled playback before modifying routes |
| OEM Bluetooth APK | SdBluetooth 2.0.8 code 48 | SdBluetooth 1.9.5 code 35, different content | r53 pairing/contacts; r54 parser experiment | Runtime confirms app/serial JNI presence, but phone behavior remains untested |
| OEM BT native daemon | old `sdsdk816` | executable code changed; runtime owns `/dev/ttyHS1` and PTY infrastructure | r53 working transport/contacts | Strong hardware-OEM dependency candidate; phone-plane necessity/function still needs targeted capture |
| System Bluetooth | older Bluetooth APEX APK | Bluetooth APK changed; Android BT HAL uses `/dev/ttyHS0` | separate from OEM UART/PTY path | Keep system BT and OEM second-BT planes separate |
| Wi-Fi kernel module | `qca_cld3_wlan.ko` | `.text` identical; `.data`/build-id differ | r31 restored init/module load | No evidence beta replaces historical OEM/vendor initialization need |
| Adreno vendor libs | baseline | identical | display stack | No static evidence of an Adreno driver update |
| Wi-Fi ADB | init behavior present | used successfully for runtime collection | r56 network ADB | Diagnostic facility, not hardware support evidence |

## Porting contracts from runtime evidence
Treat these as demonstrated contracts, not instructions to clone the whole DUDU implementation:
1. USB gadget/accessory/AOA lifecycle compatible with the stock projection flow.
2. Reverse-side access to `/dev/usb_accessory`.
3. Working display capture/media interfaces and Qualcomm AVC encoding path.
4. `/dev/virtual_input` or an equivalent compatible return-input mechanism.
5. Legacy Qualcomm vendor/VNDK30 audio stack compatibility.
6. Correct mixed ARM32/ARM64 runtime support for any retained OEM components.

## Old-fix reassessment
- r34-r35 stock-style lifecycle remains relevant as historical control evidence, but the exact old patch is not proven necessary by this capture.
- r53 OEM BT transport remains relevant; runtime confirms UART/PTY architecture, but pairing/contacts/calls were not tested here.
- r54 parser patch remains an unvalidated diagnostic/workaround candidate.
- r74 audio-policy visibility remains a GSI-compat issue.
- r74/r77 mixer initialization is not established as a stock requirement.
- r88/r88f fixed RX loopback is not a baseline HUR video/touch requirement; stock works with `AFE_LOOPBACK_TX Port=None` in this scenario.
- r88g 60-fps/offload assumptions are not validated; observed stock HUR setup requested 1920x1080 at 30 fps.

## Next runtime questions
1. Controlled local playback start/pause/resume/stop with synchronized PCM, AudioFlinger, AudioPolicy and mixer snapshots: identify `ght-play` and the actual audible route.
2. Tablet-side HUR timestamps/logs for first attach/frame/touch if deeper latency/timing analysis becomes necessary.
3. Socket inventory for reverse/MainAiBox/SpeedPlay/sdsdk if IPC orchestration must be isolated.
4. Qualcomm media encoder service maps/FD if exact vendor encoder dependencies are needed.
5. Explicit enforcing experiment only after policy planning; current stock evidence is permissive.
6. Separate OEM Bluetooth phone test for pairing, contacts, HFP/call audio and reconnect.

## Transfer rule
The September beta is a complete reference, not a bag of newer donor files. A component becomes a porting candidate only after its current dependency chain and the target failure are both demonstrated.