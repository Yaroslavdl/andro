---
name: selinux-bringup
description: Diagnose and fix SELinux issues during Android/LineageOS device bring-up. Use for AVC denials, mislabeled files/devices, service domains, property contexts, hwservice/service contexts, neverallow failures, and vendor policy integration.
---

# SELinux Bring-up

## Non-negotiable rule
Never convert audit2allow output directly into policy without understanding the access path.

## For each denial
1. Capture the complete AVC and nearby logs.
2. Identify source domain, target type, class and permission.
3. Identify the actual object/path/service/property involved.
4. Verify whether the source process is in the intended domain.
5. Verify file/service/property/hwservice labels and transitions.
6. Compare stock labels/policy behavior when available.
7. Check whether the operation should occur at all.
8. Check existing AOSP/Lineage macros and analogous same-generation devices.
9. Check neverallow constraints.
10. Propose the minimum correct labeling/domain/policy change.

## Prefer root fixes
Prefer correcting file_contexts, property_contexts, service_contexts, hwservice_contexts, domain transitions, ownership or service configuration when they are the real cause. Broad allow rules are a last resort, not a bring-up shortcut.

## Validation
Rebuild policy, verify no neverallow/regression, boot enforcing, reproduce the feature, and confirm the original denial is gone without creating a broad new access path.