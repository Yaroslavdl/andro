---
name: vendor-blob-analysis
description: Analyze and integrate proprietary vendor blobs for LineageOS bring-up. Use for missing libraries, symbol/linker errors, proprietary-files.txt, extraction, ELF dependencies, firmware/config blobs, and blob fixups.
---

# Vendor Blob Analysis

## Workflow
1. Identify the exact failing binary/library/service from logs.
2. Locate the stock artifact and its partition/path.
3. Inspect architecture, ELF dependencies, SONAME, required symbols, and related config/firmware files.
4. Compare against current Lineage vendor extraction lists and generated vendor tree.
5. Determine whether the problem is: missing blob, wrong version, missing dependency, wrong destination, missing symlink, incompatible namespace/VNDK expectation, absent config, or required blob fixup.
6. Add only the required artifacts and document why.
7. Re-extract/regenerate vendor files and run a targeted build/test.

## Checks
Use `file`, `readelf -h/-d/-s`, `nm -D` where useful. Inspect linker errors before adding dependencies. Check both 32-bit and 64-bit variants. Keep firmware and XML/config dependencies in scope.

## Rules
Do not solve symbol errors by blindly copying large sets of stock libraries. Avoid replacing AOSP libraries with proprietary versions unless compatibility evidence requires it. Preserve extraction reproducibility through `proprietary-files.txt` and the device's supported extraction/fixup mechanism.