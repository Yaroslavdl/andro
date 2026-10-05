# Audio dependency map

## Known evidence
- General audio worked in some previous Lineage builds.
- Later builds introduced audio regressions.
- Bluetooth call audio remained incomplete.

## Use cases
| Use case | DUDU | Old Lineage | Target | Evidence |
| --- | --- | --- | --- | --- |
| local/media playback | ? | known-good then regressed | ? | |
| CP/AA media | ? | ? | ? | |
| Bluetooth media | ? | ? | ? | |
| call downlink | ? | partial/broken | ? | |
| microphone/uplink | ? | unverified | ? | |

## Chain to resolve
`AudioService/policy -> Audio HAL -> OEM/vendor routing -> mixer controls -> kernel codec/PCM path -> head unit / microphone`

First priority is to identify the last known-good ordinary-audio build and diff it against the first regression.