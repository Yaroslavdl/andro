# X21-SC162 bring-up plan

## Phase 0 — Recover project history
Before inventing new fixes, analyze `D:/carlinkit/Carlinkit_aosp11/` and recover the exact modifications behind successful Lineage 18.1 builds.

Produce a ledger with columns:
- artifact/build
- changed file or image
- subsystem
- change
- reason/evidence if known
- first build containing change
- last known-good build
- whether still required on a modern base

Prioritize recovered fixes for boot, CP/AA, display, touch, resolution, Wi-Fi, LTE, LED, audio and OEM Bluetooth.

## Phase 1 — Baseline DUDU
Collect a reproducible working-state snapshot from DUDU:
- full getprop
- service list
- relevant dumpsys output
- `lshal` where available/useful
- process list with command lines and SELinux domains
- loaded kernel modules
- dmesg from boot
- logcat from boot and subsystem actions
- mounts and filesystem/block layout
- VINTF manifests/matrices
- init service definitions
- audio policy/config and mixer files
- Bluetooth configs/services
- telephony/radio state

## Phase 2 — Build the dependency map
For each important subsystem, map:
`framework/client -> service -> HAL -> vendor library/daemon -> device node/sysfs -> kernel driver/module -> firmware/config`

Start with:
1. CP/AA and display/touch path
2. Wi-Fi
3. LTE/radio
4. audio
5. OEM/secondary Bluetooth
6. microphone
7. power/suspend

## Phase 3 — Modern Lineage userspace strategy
Do not assume a full device-source build is immediately possible. Evaluate the least risky path from the evidence:
- modern GSI plus compatibility/vendor integration,
- a gradually reconstructed device/product configuration,
- or a fuller source-built target if enough board/kernel/vendor information is recovered.

DUDU proves the legacy Android 11 vendor stack can support an Android 15 system in at least one working configuration. Identify DUDU's compatibility mechanisms before changing vendor components.

## Phase 4 — Bring-up order
1. boot and recovery path
2. stable ADB/root diagnostics during development
3. CP/AA image output and touch
4. resolution adaptation
5. Wi-Fi
6. LTE/data
7. general audio
8. OEM/secondary Bluetooth
9. microphone and call audio routing
10. telephony/IMS only if required and testable
11. LED and auxiliary OEM functions
12. suspend/power/reliability

## Regression rule
For any subsystem that once worked in the old port, first perform a known-good vs regression diff before introducing a new stock-derived fix.