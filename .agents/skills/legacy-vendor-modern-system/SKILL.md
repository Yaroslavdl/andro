---
name: legacy-vendor-modern-system
description: Use when debugging compatibility between a modern Android system and an older vendor/ODM stack, especially X21-SC162 where Android 15 system/product runs with Android 11 vendor/ODM and a 4.19 kernel.
---

# Legacy vendor + modern system compatibility

The primary reference already demonstrates this architecture working:
- system/system_ext/product: Android 15 / SDK 35
- vendor/odm: Android 11 / SDK 30
- first API level: 30
- kernel: 4.19.157-perf

Therefore, never claim that the generation mismatch alone explains a failure.

## Goal
Determine the exact compatibility mechanism used by DUDU and reproduce only the required pieces on the target userspace.

## Compare
- VINTF device/framework manifests and compatibility matrices
- shipping/first API level related properties
- vendor interface declarations
- init services and service overrides
- linker namespaces and vendor library availability
- system/vendor properties
- framework compatibility packages and shims
- permissions/XML declarations
- SELinux policy boundaries
- binderized/passthrough HAL behavior where relevant
- AIDL/HIDL service registration

## Failure workflow
For a missing/broken service:
1. Capture exact client/framework error.
2. Determine expected interface and instance.
3. Check whether DUDU registers it and from which binary.
4. Resolve binary libraries and configuration.
5. Compare VINTF declaration and init startup.
6. Compare relevant properties and SELinux state.
7. Identify whether the mismatch is framework expectation, registration, linker/dependency, policy, or kernel/device access.
8. Implement the smallest compatibility fix.

## Anti-patterns
Do not:
- replace the whole vendor because it is old,
- spoof API/version properties globally without identifying the consumer,
- add broad compatibility matrices merely to silence checks,
- add random shim libraries without a demonstrated unresolved dependency.