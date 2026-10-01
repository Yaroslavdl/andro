# Known subsystem status

`?` means not sufficiently verified, not necessarily broken.

| Subsystem | DUDU reference | Previous Lineage port | New port |
| --- | --- | --- | --- |
| Boot | OK | OK | ? |
| CP/AA integration | OK | OK | ? |
| Image output | OK | OK | ? |
| Physical touch | OK | OK | ? |
| Resolution adaptation | OK | OK | ? |
| Wi-Fi | OK | OK | ? |
| LTE | ? | OK | ? |
| LED | ? | OK | ? |
| Google Play | ? | OK | ? |
| General audio | ? | PARTIAL / regressed later | ? |
| OEM/secondary Bluetooth | ? | PARTIAL | ? |
| Bluetooth phone pairing | ? | OK in successful builds | ? |
| Bluetooth contacts | ? | OK in successful builds | ? |
| Bluetooth call audio | ? | BROKEN/PARTIAL | ? |
| Bluetooth call history | ? | BROKEN/PARTIAL | ? |
| Bluetooth stability | ? | PARTIAL | ? |
| Microphone | ? | UNKNOWN | ? |
| IMS/VoLTE | ? | UNKNOWN | ? |
| Suspend/power behavior | ? | ? | ? |

## Scope notes
- Camera, fingerprint and NFC are not bring-up targets unless hardware presence is independently established.
- Update this table only from explicit test evidence.
- Record regressions against the nearest known-good build, not just against DUDU.