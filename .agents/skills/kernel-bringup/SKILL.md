---
name: kernel-bringup
description: Diagnose kernel-side Android hardware bring-up issues. Use for driver probe failures, GKI/vendor modules, defconfig, DT/DTBO, firmware loading, sysfs/procfs state, boot logs, module dependencies and kernel/userspace contract mismatches.
---

# Kernel Bring-up

## Workflow
1. Determine kernel version, GKI/vendor split, module partitions and module load mechanism.
2. Start from dmesg: identify probe errors, deferred probes, missing firmware, missing symbols, permission failures, device-node creation, regulator/clock/GPIO/IOMMU issues.
3. Compare stock and Lineage module lists, module load order, kernel config and relevant DT/DTBO nodes.
4. Check firmware paths and filenames exactly.
5. Verify expected `/dev`, `/sys`, `/proc` interfaces used by the Android HAL/service.
6. Distinguish kernel failure from userspace failure before changing kernel code.
7. Prefer config/DT/module/firmware integration fixes over source changes when evidence supports them.
8. Rebuild the narrowest artifact possible and retest from boot logs upward.

## Useful evidence
`uname -a`, `/proc/config.gz` where available, `lsmod`, `/proc/modules`, module metadata, `dmesg`, sysfs state, stock boot/vendor_boot contents, DT/DTBO decompilation, firmware load messages.

Do not enable large sets of kernel options or copy entire stock module sets without mapping them to the failing hardware path.