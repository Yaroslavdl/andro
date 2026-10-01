---
name: stock-rom-analysis
description: Analyze an OEM stock Android firmware as the reference implementation for LineageOS bring-up. Use for extracted partitions, boot images, init, properties, VINTF, HALs, firmware, modules, SELinux, and runtime captures.
---

# Stock ROM Analysis

Use stock firmware as evidence, not as a source of assumptions.

## Workflow
1. Identify Android version, vendor API level, security patch, architecture, dynamic partition layout, kernel version, and GKI status where possible.
2. Inventory extracted partitions: system, system_ext, product, vendor, odm, vendor_dlkm, system_dlkm.
3. Inventory boot artifacts: boot, vendor_boot, init_boot, dtb, dtbo.
4. Capture or inspect runtime evidence: getprop, logcat, dmesg, service list, lshal, dumpsys, mount, module state, firmware load errors.
5. Map hardware feature -> service/HAL -> binary/library -> init rc -> VINTF -> SELinux -> kernel driver/module -> firmware/config.
6. Record findings in a concise evidence table.

## Useful searches
- `find vendor odm -type f | sort`
- `grep -R "android.hardware" vendor/etc/vintf odm/etc/vintf`
- `grep -R "service " vendor/etc/init odm/etc/init`
- `grep -R "ro.vendor\|persist.vendor\|vendor." vendor/build.prop odm/build.prop product/build.prop 2>/dev/null`
- `readelf -d <binary-or-library>` / `llvm-readelf -d`
- `file <artifact>` and `strings <artifact>` only when they add evidence.

## Output
Report: subsystem, stock implementation path, runtime service/HAL, dependencies, relevant properties/config, SELinux context, kernel/module/firmware dependency, and unknowns.

Do not propose Lineage changes until the stock implementation is understood well enough to explain the observed behavior.