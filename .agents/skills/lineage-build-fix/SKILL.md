---
name: lineage-build-fix
description: Diagnose and fix LineageOS/AOSP build failures involving Soong, Ninja, Android.bp, Make product configuration, missing modules, duplicate modules, dependency cycles, generated vendor trees, SELinux compilation and kernel integration.
---

# LineageOS Build Failure Triage

## Workflow
1. Capture the first real error, not only the final Ninja failure summary.
2. Classify it: product config, Soong/Blueprint parsing, missing module, duplicate module, dependency/link error, generated vendor artifact, SELinux compilation, kernel build, packaging, VINTF compatibility, or host tooling.
3. Identify the module and owning repository/path.
4. Inspect the relevant `Android.bp`, makefile/product inheritance, namespace visibility, generated vendor definitions, or policy input.
5. Check whether a recent bring-up change caused the failure before adding workarounds.
6. Make the smallest source/configuration correction.
7. Run the narrowest useful rebuild (`m <module>`, `mm`, `mmm`, image target, or equivalent), then return to the full device build.

## Rules
- Do not clean the whole tree as the first response to a deterministic build error.
- Do not hide missing dependencies with arbitrary optional flags.
- Treat duplicate modules and namespace problems as ownership/configuration issues.
- When generated vendor files are involved, fix the extraction/generator source rather than only the generated output.
- For SELinux build errors, use the SELinux bring-up workflow instead of disabling checks.

## Report
First real error -> classification -> responsible module/path -> cause -> minimal patch -> targeted rebuild command -> full verification.