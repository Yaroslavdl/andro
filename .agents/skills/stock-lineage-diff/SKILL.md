---
name: stock-lineage-diff
description: Compare a failing LineageOS subsystem with working OEM stock firmware to identify the smallest evidence-backed mismatch and fix. Use for camera, audio, Wi-Fi, Bluetooth, sensors, biometrics, display, telephony, GNSS, NFC, USB and other bring-up issues.
---

# Stock vs Lineage Differential Bring-up

This is the central bring-up workflow.

## Procedure
1. Define one reproducible symptom on LineageOS.
2. Collect Lineage evidence first: relevant logcat tags, dmesg, getprop subset, service/HAL state, dumpsys, files/contexts involved.
3. Map the failing path from framework/service down to vendor HAL and kernel when applicable.
4. Inspect the equivalent working stock path.
5. Diff only relevant layers:
   - properties
   - init rc and service arguments/users/groups/capabilities
   - VINTF manifests/matrices
   - permissions/features XML
   - overlays/resources
   - HAL binaries and shared-library dependencies
   - proprietary blobs and symlinks
   - SELinux labels/policy
   - fstab/mounts/ownership
   - kernel config/modules/DT/firmware
6. Form a root-cause hypothesis that explains both the Lineage failure and stock success.
7. Propose the smallest fix.
8. Specify a targeted verification test before broad cleanup.

## Rules
- Correlation is not root cause. A difference is actionable only if it plausibly participates in the failing path.
- Do not copy entire stock directories into Lineage.
- Do not add unrelated properties because another device tree has them.
- Prefer existing Lineage patterns from devices with the same SoC/vendor generation when stock alone does not show the integration pattern.

## Report format
Symptom -> Lineage evidence -> stock evidence -> meaningful difference -> hypothesis -> minimal patch -> targeted retest -> confidence/unknowns.