---
name: boot-bringup
description: Diagnose Android boot failures during LineageOS bring-up. Use for bootloops, early init failures, first-stage mount, fstab, AVB-related diagnostics, vendor_boot/init_boot, ramdisk, module loading and service startup ordering.
---

# Boot Bring-up

## First classify the failure
- bootloader/fastboot stage
- kernel does not reach init
- first-stage init / mount failure
- second-stage init failure
- zygote/framework bootloop
- SystemUI/user-space crash loop

## Workflow
1. Collect the earliest available serial/dmesg/logcat/last_kmsg/pstore evidence.
2. Identify the last successful stage rather than debugging late symptoms first.
3. Compare stock vs Lineage boot, vendor_boot and init_boot composition where relevant.
4. Inspect fstab, dynamic partitions, first-stage mount, device nodes, module loading, init imports and service ordering.
5. Check ramdisk file placement and permissions/contexts.
6. Check kernel command line/bootconfig differences only when they plausibly affect the failure.
7. Use AVB/security changes only as diagnostic isolation when explicitly needed; do not make security weakening the permanent fix.
8. Retest the earliest failed stage after every change.

## Report
State exact boot stage, first meaningful error, upstream dependency causing it, stock difference, minimal fix and how to verify progression to the next stage.