# Known subsystem status

`?` means not sufficiently verified, not necessarily broken.

| Subsystem | DUDU reference | Previous Lineage port | New port |
| --- | --- | --- | --- |
| Boot | OK | OK | ? |
| CP/AA integration | OK — HUR USB/AOA runtime confirmed on 260926 | OK | ? |
| Image output | OK — HUR video/AVC path confirmed on 260926 | OK | ? |
| Physical touch | OK — `/dev/virtual_input` return path confirmed on 260926 | OK | ? |
| Resolution adaptation | OK | OK | ? |
| Wi-Fi | OK | OK | ? |
| LTE | ? | OK | ? |
| LED | ? | OK | ? |
| Google Play | ? | OK | ? |
| General audio | OK for tested local AAC media -> HUR path; dynamic offload/TERT route confirmed | PARTIAL / regressed later | ? |
| OEM/secondary Bluetooth | ? — runtime UART/PTY stack present, phone behavior not tested | PARTIAL | ? |
| Bluetooth phone pairing | ? | OK in successful builds | ? |
| Bluetooth contacts | ? | OK in successful builds | ? |
| Bluetooth call audio | ? | BROKEN/PARTIAL | ? |
| Bluetooth call history | ? | BROKEN/PARTIAL | ? |
| Bluetooth stability | ? | PARTIAL | ? |
| Microphone | ? | UNKNOWN | ? |
| IMS/VoLTE | ? | UNKNOWN | ? |
| Suspend/power behavior | ? — device is batteryless; normal test lifecycle is cold power-on from head unit/tablet | ? | ? |

## 260926 validated HUR runtime reference
Reference captures:
- `06_live_logs/boot_hur/boot_hur_20261002_161047`
- `06_live_logs/audio_events/hur_audio_20261002_171124`

Confirmed on the tested tablet/HUR topology:
- X21 is powered by the tablet/head-unit side; there is no battery-backed pre-connect state.
- USB/AOA negotiation succeeds and HUR identifies itself as the head unit.
- `sdAutoReverse` child is the directly evidenced stock projection executor: `/dev/usb_accessory`, AA/TLS/auth, screen/video path and `/dev/virtual_input` touch return.
- Qualcomm AVC encoder participates in the working video path.
- MainAiBox has a PTY control link into the OEM stack.
- `sdsdk816` owns the OEM UART/PTY infrastructure; Android BT HAL and OEM BT use separate UARTs in this capture.
- Controlled local AAC playback produced audible sound on the tablet through HUR for PLAY and RESUME and silence for PAUSE and STOP.
- Audible states correlate with an active AAC LC 44.1 kHz compressed-offload output and policy media patch.
- `AFE_LOOPBACK_TX Port` dynamically changes `None -> TERT_MI2S_RX -> None` with playback state; related AFE/TERT mixer controls change with it.
- Reverse child owns `/dev/snd/pcmC0D1c` capture and `/dev/usb_accessory`; this is strong evidence that reverse participates in local-speaker-audio transport to HUR, though the internal PCM-to-AA-packet chain is not yet directly traced.
- `ght-play` keeps `pcmC0D4p` running S16_LE/stereo/48 kHz in both audible and silent states. It is a confirmed persistent direct-PCM helper, but its exact function and necessity remain unresolved.
- Do not promote old fixed-loopback mixer workarounds to baseline requirements. The tested stock route is dynamic, not permanently `None` or `RX_CDC_DMA_RX_0`.

## Audio caveats
- Current proof is for the tested local AAC/offload path. Ordinary PCM/WAV playback has not yet been isolated.
- `pcmC0D6c` follows audible states but is attributed to the Qualcomm offload visualizer capture; do not confuse it with projection transport.
- `C0D1c` reverse capture remains RUNNING even in silent states; RUNNING alone does not prove non-zero samples.
- A new media/offload start occurred shortly after the STOP snapshot in the first controlled capture. Future captures must include a post-stop observation window and precise operator markers.

## Scope notes
- Camera, fingerprint and NFC are not bring-up targets unless hardware presence is independently established.
- Update this table only from explicit test evidence.
- Record regressions against the nearest known-good build, not just against DUDU.
- A stock OEM component being active does not prove that an equivalent Lineage implementation must copy that exact APK/binary; preserve the demonstrated hardware/vendor contract unless necessity is isolated.