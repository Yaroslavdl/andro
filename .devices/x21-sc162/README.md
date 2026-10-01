# X21-SC162 knowledge base

This directory is the device-specific context layer for the Carlinkit TBox Ultra / Ultra 2 module identified in firmware materials as X21-SC162.

Read in this order:
1. `DEVICE.md` — hardware/software identity and known facts.
2. `REFERENCES.md` — hierarchy of evidence and working references.
3. `PARTITIONS.md` — currently known image/partition architecture.
4. `KNOWN_STATUS.md` — subsystem status matrix.
5. `OLD_PORT_LEDGER.md` — evidence-backed late PHH/Lineage history and mandatory fix classification gate.
6. `BRINGUP.md` — phased bring-up plan.
7. `LOCAL_IMPORT.md` — how to analyze and sanitize local project/stock evidence.

Related device-specific skills:
- `qcom-lito-sm6350`
- `legacy-vendor-modern-system`
- `carlinkit-connectivity`
- `qcom-audio-bringup`
- `qcom-bluetooth-bringup`
- `gsi-to-device-port`

## Historical workspace split
- `C:/Carlinkit_phh_v313/` is the primary source for the late PHH -> Lineage 18 port history (r30-r88g artifacts where preserved).
- `D:/carlinkit/Carlinkit_aosp11/` is the earlier experimental/control branch.
- `D:/carlinkit/DUDU_stock_opt/2608121631_2608120956/` is the primary modern working reference.

## Current milestone
Build a DUDU-vs-historical comparison around the strongest control points (r53, r56, r74/r77, r88/r88f) and use it to separate persistent hardware/OEM dependencies from obsolete GSI/PHH workarounds.