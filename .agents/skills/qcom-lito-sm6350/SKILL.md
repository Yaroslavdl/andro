---
name: qcom-lito-sm6350
description: Use for X21-SC162 Qualcomm SM6350/lito platform investigation, especially kernel, DTBO, Qualcomm vendor services, firmware, modules, device nodes and subsystem dependency tracing.
---

# Qualcomm SM6350 / lito investigation

Target context: Carlinkit X21-SC162, Snapdragon 690 / SM6350, Adreno 619, legacy Qualcomm Android 11 vendor/ODM, kernel 4.19.157-perf.

## Rules
- `lito` is a platform identifier, not proof of a unique device codename.
- Prefer evidence from this device's stock images and runtime over assumptions from other lito devices.
- Other SM6350/lito device trees may be used as comparative references only. Never transplant board config, DT, firmware, modem, calibration or proprietary blobs solely because the SoC matches.

## Investigation workflow
1. Identify the failing Android service/HAL or observable device-node failure.
2. Trace its vendor libraries and daemon dependencies.
3. Find corresponding init definitions and properties.
4. Identify `/dev`, `/sys`, `/proc` interfaces used by the component.
5. Map those interfaces to kernel drivers/modules and DT/DTBO nodes where possible.
6. Check firmware/calibration/config dependencies.
7. Compare DUDU runtime to the failing target.
8. Propose the smallest evidence-backed change.

## Kernel/module evidence
Record:
- `uname -a`
- `/proc/config.gz` if exposed
- loaded modules and module parameters
- module files present in stock
- dmesg driver probe failures
- firmware load requests/failures
- relevant DT/DTBO compatible strings

## Qualcomm-specific caution
Do not treat generic Qualcomm service names as sufficient root cause. Follow the actual dependency chain on X21-SC162. Distinguish platform-common Qualcomm components from OEM CP/AA, Bluetooth, audio and modem integration.