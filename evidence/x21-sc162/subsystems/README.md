# Subsystem maps

Create one evidence-backed dependency map per subsystem.

Recommended first files:
- `cpaa-map.md`
- `audio-map.md`
- `bluetooth-map.md`
- `lte-radio-map.md`
- `wifi-map.md`

Use this chain where applicable:

`framework/client -> OEM service -> HAL -> vendor daemon/library -> device node/sysfs -> kernel driver/module -> firmware/config`

Record DUDU behavior, old Lineage behavior, target behavior, evidence paths and remaining unknowns separately.