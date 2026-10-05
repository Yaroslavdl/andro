# Reference hierarchy

Use evidence in this order while bringing up X21-SC162.

## 1. DUDU 2608121631_2608120956
Primary working reference. It demonstrates a modern Android 15 system on the legacy Qualcomm Android 11 vendor/ODM and 4.19 kernel stack.

Use it to answer:
- Which HALs and services actually run?
- Which vendor/ODM files are loaded at runtime?
- Which properties gate subsystem behavior?
- Which init services and OEM daemons participate?
- Which VINTF compatibility declarations are required?
- How are CP/AA, Bluetooth, audio, LTE and Wi-Fi wired together?

## 2. Original Carlinkit Android 15 stock
Secondary OEM reference. Use it to distinguish platform requirements from DUDU-specific implementation choices and to identify Carlinkit-specific CP/AA integration.

## 3. Last known-good Lineage 18.1 port artifacts
These are evidence of fixes already discovered by the project. Do not dismiss them because the base was an old GSI. Recover and classify every modification that enabled boot, CP/AA, display, touch, resolution, Wi-Fi, LTE, LED, audio and partial OEM Bluetooth.

## 4. Failed/intermediate Lineage builds
Use these for regression analysis. Compare each failing build to the nearest known-good build rather than comparing only to stock.

## Evidence strength
Prefer, in descending order:
1. Runtime evidence from a working device.
2. Authoritative original partition image contents and metadata.
3. Boot image / DTBO / kernel evidence.
4. OEM scripts, init files, manifests and configuration.
5. Analysis copies such as Windows-extracted filesystem trees.
6. Naming-based inference only as a last resort.

Never treat the presence of a package, HAL, library or config file as proof that the corresponding physical hardware exists.