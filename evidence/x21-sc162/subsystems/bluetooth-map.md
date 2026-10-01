# OEM Bluetooth dependency map

## Historical capability matrix
| Capability | Previous Lineage |
| --- | --- |
| phone pairing | working |
| contacts | working |
| call audio | incomplete/broken |
| call history | incomplete/broken |
| connection stability | intermittent disconnects |
| microphone/uplink | unverified |

## Components to identify
- standard Android Bluetooth services actually active
- OEM/secondary Bluetooth APK/service/daemon
- transport/HCI or other hardware interface ownership
- contact synchronization implementation
- call-control implementation
- audio route ownership
- reconnect/watchdog logic

## Dependency chain
Do not assume a standard Android-only chain. Populate from evidence:
`phone -> radio/transport -> Android or OEM BT service -> profile/control/data services -> audio/call integration`

## First priority
Recover the old modifications that enabled pairing and contacts, then compare them to DUDU before touching call-audio routing.