# DUDU reference matrix: 260812 -> 260926 beta

This document records the static comparison between:
- baseline: `2608121631_2608120956`
- public beta: `2609261951_2609241005` / DUDUAUTO C3

Source static analysis date: 2026-10-01. Runtime evidence for 260926 was collected on 2026-10-02 using cold power-on -> automatic HUR projection and a controlled local-media audio transition capture.

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
Reference captures:
- `06_live_logs/boot_hur/boot_hur_20261002_161047`
- `06_live_logs/audio_events/hur_audio_20261002_171124`

Physical topology: the batteryless X21 is powered by the tablet, and that same tablet runs Headunit Reloaded as the head unit. A phone is not part of these tests.

Confirmed working stock projection path:

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

Cold-boot evidence shows AOA switch, successful TLS/auth, explicit HUR identification, channel setup, video start, Qualcomm AVC encoder initialization, frame production and touch events.

Runtime dependency evidence:
- `sdAutoReverse`: `libSdAutoReverse.so`, `libCoreUtils.so`, `libtinyalsa.so` loaded.
- SpeedPlay: `libSdCarplay.so`, `libSdAuto.so`, `libSdMirrorSwitchAoa.so`, `libsd_wapm.so`, AirPlay libraries and `libCoreUtils.so` loaded. Loading does not prove each feature/path is active.
- Audio HAL: `audio.primary.lito.so`, ACDB libraries and VNDK30 tinyalsa loaded.
- MainAiBox and SdBluetooth load ARM64 `libcarsyso_serial_port.so`.
- `ght-play` loads lib64 tinyalsa and holds `pcmC0D4p` running S16_LE/stereo/48 kHz.

## Controlled HUR audio transition: 2026-10-02
Ground truth from the operator:
- idle/stopped: no local-media sound;
- PLAY: audible on tablet through HUR;
- PAUSE: silence;
- RESUME: audible on tablet through HUR;
- STOP: silence.

The HUR projection session remained active throughout.

Observed stock media behavior:
- Audible states create one active `DIRECT|COMPRESS_OFFLOAD|NON_BLOCKING` AAC LC output at 44.1 kHz stereo, logical device SPEAKER.
- AudioPolicy media active count changes 0 -> 1 -> 0 -> 1 -> 0 and patch count 4 -> 5 -> 4 -> 5 -> 4.
- `AFE_LOOPBACK_TX Port` changes `None -> TERT_MI2S_RX -> None -> TERT_MI2S_RX -> None` with the audible state.
- Related `AFE_PCM_RX ... MultiMedia4/MultiMedia7` and `TERT_MI2S_RX ... MultiMedia4` mixer controls follow the same state.
- `pcmC0D6c` runs only in audible states and is attributed to Qualcomm offload visualizer capture; it is not established as the projection transport.
- Reverse `pcmC0D1c` remains RUNNING at S16_LE/stereo/48 kHz in all states. Reverse also owns `/dev/usb_accessory` and reports speaker-source byte counts near 192 kB/s. This is strong evidence for participation in local-audio transport, but exact sample-to-AA-packet flow remains untraced.
- `ght-play`/`pcmC0D4p` remain unchanged and RUNNING in both audible and silent states. `ght-play` is therefore not proven to be the media sample sink; its backend/DSP role remains unresolved.

Important interpretation: the stock path is dynamically routed. Neither permanent `AFE_LOOPBACK_TX Port=None` nor a fixed `RX_CDC_DMA_RX_0` describes the working local-media sequence.

A new `com.syu.music`/offload start appeared shortly after the STOP snapshot in the first controlled capture. This does not invalidate the five snapshots, but future captures must use precise action markers and a post-stop observation window.

## Matrix

| Area | 260812 baseline | 260926 beta | Old Lineage control point | Porting interpretation |
| --- | --- | --- | --- | --- |
| Platform generation | A15 system + A11 vendor/ODM + 4.19 kernel | same | Lineage 18.1/GSI on same legacy vendor generation | Confirms the mixed-generation architecture remains intentional |
| CP/AA shell/init path | baseline `sd-reverse.sh`/related rc | compared scripts/rc unchanged | r34-r35 restored stock-style mode lifecycle | Do not invent a new shell lifecycle from the beta; investigate changed native/OEM code |
| CP/AA runtime | not re-measured here | HUR USB/AOA + AA/TLS/auth + video + touch confirmed | historical working CP/AA | Preserve demonstrated transport/video/input contracts |
| CP/AA native stack | baseline | native reverse stack changed | historical OEM donor/integration work | Runtime identifies `sdAutoReverse` child as directly evidenced HUR executor |
| Video encoder | legacy Qualcomm media stack | working HUR initializes Qualcomm AVC encoder | old display/projection path | Qualcomm AVC/media compatibility is a strong port contract |
| Touch return | stock reverse path | `/dev/virtual_input` used by reverse child | previous physical touch worked | Kernel/device-node/input contract is a strong requirement |
| Audio HAL | `audio.primary.lito.so` baseline | unchanged binary; runtime-loaded | old vendor audio | Preserve legacy vendor/VNDK30 audio compatibility |
| Local media route | not isolated | AAC offload + dynamic TERT route + reverse capture produces audible HUR output | r74/r77/r88f/r88g experiments | Preserve dynamic vendor/OEM behavior; do not hard-code old experimental route |
| Audio policy XML | baseline | unchanged and runtime-used | r74 PHH hid `/vendor/etc/audio` | r74 remains a GSI visibility workaround |
| Mixer routes | baseline | audible local media uses dynamic None<->TERT_MI2S_RX | r58/r88f used RX_CDC_DMA_RX_0 | r88f fixed route is obsolete/unproven as universal fix |
| `ght-play` | present | persistent C0D4p helper unchanged across audible/silent states | historical audio experiments | Exact function unresolved; not proven media sink and not safe to remove yet |
| Reverse audio | baseline | reverse owns C0D1c capture + USB accessory during successful audio | old projection/audio work | Strong hardware-OEM contract candidate; exact internal packet chain still unknown |
| OEM Bluetooth APK | SdBluetooth 2.0.8 code 48 | SdBluetooth 1.9.5 code 35 | r53 pairing/contacts | phone behavior still untested |
| OEM BT native daemon | old `sdsdk816` | changed executable; runtime owns `/dev/ttyHS1` and PTYs | r53 transport | Strong hardware-OEM dependency candidate |
| System Bluetooth | older Bluetooth APEX APK | Bluetooth APK changed; HAL uses `/dev/ttyHS0` | separate from OEM UART/PTY | Keep system and OEM BT planes separate |

## Porting contracts from runtime evidence
Treat these as demonstrated contracts, not instructions to clone the whole DUDU implementation:
1. USB gadget/accessory/AOA lifecycle compatible with the stock projection flow.
2. Reverse-side access to `/dev/usb_accessory`.
3. Working display capture/media interfaces and Qualcomm AVC encoding path.
4. `/dev/virtual_input` or equivalent touch return.
5. Legacy Qualcomm vendor/VNDK30 audio HAL/DSP/ALSA and policy compatibility.
6. Dynamic media route management equivalent to the observed stock playback lifecycle; do not substitute a permanently forced mixer route without evidence.
7. Reverse access to the stock-equivalent speaker capture path while projection remains active.
8. Correct mixed ARM32/ARM64 runtime support for retained OEM components.

## Old-fix reassessment
- r34-r35 stock-style lifecycle remains relevant historical control evidence.
- r53 OEM BT transport remains relevant; phone-plane behavior still needs a targeted capture.
- r54 parser patch remains an unvalidated diagnostic/workaround candidate.
- r74 audio-policy visibility remains `gsi-compat`; it is not a stock mechanism.
- r74/r77 mixer initializer is `diagnostic-workaround`; stock routing is demonstrably dynamic and the old initializer's necessity is unproven.
- r88 rollback is historical regression-control evidence, not a stock mechanism.
- r88f fixed `None -> RX_CDC_DMA_RX_0` is `obsolete/unproven` as a universal fix: tested audible stock media uses `TERT_MI2S_RX` and returns to `None` when silent.
- r88g offload/PCM hypotheses remain `diagnostic-workaround/unproven`; stock does successfully use AAC compressed offload in this scenario, but offload is not yet proven mandatory for all media.

## Next runtime questions
1. Repeat the controlled AAC cycle with exact operator action markers, short before/immediate/stable snapshots and a post-stop observation window.
2. Repeat with ordinary local WAV/PCM playback to determine whether TERT/reverse capture is the general media bridge or specific to compressed offload.
3. Capture full process/thread attribution plus FD/maps for player, Audio HAL, audioserver, reverse parent/child and `ght-play`.
4. Capture PCM status/hw_params plus pointer progression; separate tinymix stdout/stderr so failed array reads cannot pollute semantic diff.
5. Passively correlate reverse channel start/stop, negotiated format and audio packet/byte counters where available.
6. Separately investigate pre-experiment reverse tinyalsa read errors with a precise trigger timestamp.
7. Separate OEM Bluetooth phone test for pairing, contacts, HFP/call audio and reconnect.

## Transfer rule
The September beta is a complete reference, not a bag of newer donor files. A component becomes a porting candidate only after its current dependency chain and the target failure are both demonstrated.