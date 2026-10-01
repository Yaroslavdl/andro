---
name: hal-vintf-debug
description: Diagnose Android HAL and VINTF integration failures during LineageOS device bring-up. Use for AIDL/HIDL services, missing interfaces, service registration failures, manifest/matrix mismatches, binderized HALs, lshal and servicemanager errors.
---

# HAL / VINTF Debugging

## Workflow
1. Identify the expected interface and instance from logs or framework expectations.
2. Check whether the service process starts and stays alive.
3. Inspect stock and Lineage VINTF manifests/matrices under vendor/odm/system/system_ext/product as relevant.
4. Inspect init rc service declaration, binary path, arguments, user/group, capabilities and class.
5. Check AIDL/HIDL version and instance compatibility.
6. Check shared-library dependencies and linker namespace failures.
7. Check SELinux only after confirming process/service wiring.
8. Compare working stock registration using `lshal`, `service list`, `dumpsys`, `ps -AZ` and logs.
9. Make the smallest manifest/init/build integration fix and retest registration before testing the full feature.

## Common failure classes
- binary never starts
- binary crashes on linker/symbol/config failure
- wrong interface version or instance name
- missing manifest declaration
- framework compatibility matrix mismatch
- service registered in stock under ODM rather than vendor
- missing permissions/config/firmware dependency
- SELinux denial preventing registration or device access

Always distinguish declaration problems from runtime implementation failures.