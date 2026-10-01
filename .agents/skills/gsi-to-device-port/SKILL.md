---
name: gsi-to-device-port
description: Use when recovering knowledge from the project's previous GSI-based Lineage/PHH experiments and converting successful binary patches, scripts and configuration into a maintainable X21-SC162 port strategy.
---

# GSI-to-device port recovery

The old Lineage 18.1 work was GSI-based and had no project-owned device/vendor/kernel source trees. Its artifacts are still valuable experimental evidence.

## First task: reconstruct history
Analyze `D:/carlinkit/Carlinkit_aosp11/` when available.

Inventory:
- build scripts
- image patch scripts
- copied/replaced vendor/system files
- overlays and properties
- init changes
- SELinux changes
- fstab/mount changes
- framework patches
- PHH/Treble settings
- boot/recovery modifications
- logs associated with each build

## Build a fix ledger
For each discovered modification record:
- exact source artifact
- exact target artifact/path
- first known build using it
- subsystem
- observed effect
- evidence for why it was needed
- whether DUDU contains an analogous mechanism
- whether it is likely base-version-specific

## Classification
Classify every old fix as one of:
- hardware requirement
- Qualcomm vendor compatibility requirement
- Carlinkit OEM integration requirement
- GSI/PHH workaround
- Android 11/Lineage 18.1-specific workaround
- diagnostic-only change
- unknown

Only the first three categories should be presumed candidates for a modern port; all others require fresh evidence.

## Desired output
Produce a migration map from historical binary/image patching toward maintainable source/config changes where possible. Preserve proprietary components only when evidence shows they remain required.