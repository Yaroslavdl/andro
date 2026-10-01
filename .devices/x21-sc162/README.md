# X21-SC162 knowledge base

This directory is the device-specific context layer for the Carlinkit TBox Ultra / Ultra 2 module identified in firmware materials as X21-SC162.

Read in this order:
1. `DEVICE.md` — hardware/software identity and known facts.
2. `REFERENCES.md` — hierarchy of evidence and working references.
3. `PARTITIONS.md` — currently known image/partition architecture.
4. `KNOWN_STATUS.md` — subsystem status matrix.
5. `BRINGUP.md` — phased bring-up plan.
6. `LOCAL_IMPORT.md` — how to analyze and sanitize local project/stock evidence.

Related device-specific skills:
- `qcom-lito-sm6350`
- `legacy-vendor-modern-system`
- `carlinkit-connectivity`
- `qcom-audio-bringup`
- `qcom-bluetooth-bringup`
- `gsi-to-device-port`

## Immediate next milestone
Analyze the historical local workspace `D:/carlinkit/Carlinkit_aosp11/` and reconstruct a fix ledger for the last known-good Lineage 18.1/GSI-based builds before attempting new compatibility changes.