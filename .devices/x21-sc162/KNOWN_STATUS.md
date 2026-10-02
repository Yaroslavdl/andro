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
| General audio | ? — persistent `ght-play` PCM observed; audible role not established | PARTIAL / regressed later | ? |
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
Reference capture: `06_live_logs/boot_hur/boot_hur_20261002_161047`.

Confirmed on the tested tablet/HUR topology:
- X21 is powered by the tablet/head-unit side; there is no battery-backed pre-connect state.
- USB/AOA negotiation succeeds and HUR identifies itself as the head unit.
- `sdAutoReverse` child is the directly evidenced stock projection executor: `/dev/usb_accessory`, AA/TLS/auth, screen/video path and `/dev/virtual_input` touch return.
- Qualcomm AVC encoder participates in the working video path.
- MainAiBox has a PTY control link into the OEM stack.
- `sdsdk816` owns the OEM UART/PTY infrastructure; Android BT HAL and OEM BT use separate UARTs in this capture.
- `ght-play` keeps `pcmC0D4p` running at S16_LE/stereo/48 kHz, but its audible/projection role is not established.
- Working HUR video/touch was observed with `AFE_LOOPBACK_TX Port=None`; do not promote old fixed-loopback mixer workarounds to baseline requirements.

## Scope notes
- Camera, fingerprint and NFC are not bring-up targets unless hardware presence is independently established.
- Update this table only from explicit test evidence.
- Record regressions against the nearest known-good build, not just against DUDU.
- A stock OEM component being active does not prove that an equivalent Lineage implementation must copy that exact APK/binary; preserve the demonstrated hardware/vendor contract unless necessity is isolated.