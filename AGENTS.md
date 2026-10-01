# Android firmware bring-up workspace

This repository is used for studying OEM stock firmware and bringing LineageOS up to feature parity on a target device.

## Core rule
Treat the stock ROM as the reference implementation for hardware behavior. Do not guess when stock evidence can be collected.

## Default workflow
1. Reproduce the failure on LineageOS.
2. Collect Lineage runtime evidence: logcat, dmesg, getprop, service state, HAL state, relevant dumpsys output.
3. Inspect the corresponding stock implementation and artifacts.
4. Compare stock vs Lineage configuration, binaries, properties, init, VINTF, SELinux, firmware, kernel/module state, overlays, permissions, and blobs.
5. Form a root-cause hypothesis backed by evidence.
6. Make the smallest change that explains and fixes the mismatch.
7. Rebuild only what is necessary first, then run a broader build if needed.
8. Retest and record what changed.

## Preferred evidence sources
- Stock partitions: system, system_ext, product, vendor, odm, vendor_dlkm, system_dlkm.
- Boot artifacts: boot, vendor_boot, init_boot, dtb, dtbo.
- Runtime: getprop, logcat, dmesg, lshal, service list, dumpsys, binder/service state, procfs/sysfs where relevant.
- Device tree: BoardConfig, product makefiles, Android.bp, overlays, init rc, fstab, vintf, sepolicy, proprietary-files lists.
- Kernel: config/defconfig, module lists, DT/DTBO, firmware loading, driver probe logs.

## Safety and change discipline
- Never generate SELinux allow rules blindly from audit2allow output. First identify the source domain, target type, correct labeling, stock behavior, and neverallow constraints.
- Never add random properties, blobs, modules, or service overrides without a concrete failure signal or stock comparison.
- Prefer fixing labels, ownership, startup order, dependency declarations, VINTF mismatches, firmware paths, or missing blobs over broad policy relaxations.
- Do not weaken verified boot, SELinux enforcing mode, or other security controls as a shortcut unless the explicit task is temporary diagnostic isolation.
- Keep changes minimal and explain why each changed file is needed.

## Build strategy
Prefer targeted rebuilds when possible. Keep commands device-agnostic until the device codename and branch are known.

## Reporting format for bring-up tasks
For each issue, report:
- Symptom
- Evidence
- Stock vs Lineage difference
- Root-cause hypothesis
- Proposed minimal fix
- Files to change
- Verification steps
- Remaining uncertainty

## Skills
Use the skills under `.agents/skills/` for stock analysis, stock-vs-Lineage comparison, vendor blobs, HAL/VINTF, SELinux, kernel, boot, hardware bring-up, and build failures.
