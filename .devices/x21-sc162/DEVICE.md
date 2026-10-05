# X21-SC162 device profile

## Identity
- Product family: Carlinkit TBox Ultra / Ultra 2
- Firmware module designation: X21-SC162
- Project device ID: `x21-sc162`
- Qualcomm platform string seen in DUDU: `lito`
- Do not treat `lito` as a unique device codename; it identifies the Qualcomm platform family.
- Exact PCB/hardware revision is not yet verified.

## Hardware
- SoC: Qualcomm Snapdragon 690 / SM6350
- Platform family: lito / SD6350 naming appears in firmware artifacts
- GPU: Adreno 619
- RAM: nominally 8 GB
- Storage: UFS, capacity not yet recorded
- No built-in display or battery.
- UI is presented to the vehicle head unit through the CarPlay / Android Auto integration path.
- Camera, fingerprint and NFC hardware are not currently claimed for this box. Firmware components mentioning them are not evidence that the hardware exists.

## Primary working reference: DUDU
Build: `2608121631_2608120956`

Fingerprint: `qti/lito/lito:15/AQ3A.241126.002/duduauto.ttrnf.20260812.163156:user/release-keys`

- system/system_ext/product: Android 15, SDK 35
- vendor/odm: Android 11, SDK 30
- first API level: 30
- kernel: `4.19.157-perf`
- system security patch: 2024-09-05
- vendor security patch: 2021-04-05

This mixed-generation stack is a critical architectural fact: a working Android 15 system is already demonstrated on top of an Android 11-era Qualcomm vendor/ODM stack and 4.19 kernel. Investigate how DUDU maintains compatibility before concluding that the legacy vendor is inherently incompatible with a newer system.

## Previous Lineage experiment
Previous successful work used a generic LineageOS 18.1 Android 11 GSI, not a device-specific source build:
`lineage-18.1-20240121-UNOFFICIAL-arm64_bvS.img`

PHH v313 and Google GSIs were also tested. There is currently no project-owned device tree, vendor tree, kernel tree or common tree.

## Known previous Lineage status
- Boot: working in successful builds
- CP/AA path: working
- Image output: working
- Physical touch: working
- Resolution adaptation: working
- Wi-Fi: working
- LTE: working
- LED: working
- Google Play: working
- General audio: worked, later builds had regressions
- Secondary/OEM Bluetooth: partial; phone pairing and contacts worked, but call audio, call history and connection stability remained problematic
- Microphone: not fully verified
- IMS/VoLTE: not fully verified

## Local stock archive locations
These paths describe the maintainer's workstation and may not exist in every agent environment.

DUDU archive:
`D:/carlinkit/Carlinkit_aosp11/downloads/2608121631_2608120956.zip`

DUDU analysis workspace:
`D:/carlinkit/DUDU_stock_opt/2608121631_2608120956`

Previous project/history root of interest:
`D:/carlinkit/Carlinkit_aosp11/`

## Stock dump layout
- `01_source_copy/`: original ZIP copy
- `02_ota/`: payload.bin and OTA metadata
- `03_images/`: authoritative original partition images
- `04_files/new/`: Windows-extracted August DUDU analysis copy
- `04_files/dudu07/`: July DUDU comparison copy
- `06_live_logs/`: live-device evidence
- `reports/`: generated analysis reports
- `tools/`: analysis tooling

The OTA currently has no separate `vendor_boot.img` or `vendor_dlkm.img` in the recorded image set.

## Metadata rule
`04_files/` is an analysis/search copy only. Windows extraction may lose Linux ownership, mode bits, symlink semantics, xattrs, capabilities and SELinux labels. Never infer authoritative filesystem metadata from this tree. Use original `.img` files, filesystem-aware extraction, or live-device evidence for metadata questions.