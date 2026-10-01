# Android firmware bring-up skill pack

Codex workspace for studying OEM stock firmware and bringing LineageOS up to working hardware parity.

## Included custom skills

- `stock-rom-analysis` — inventory and understand the stock implementation.
- `stock-lineage-diff` — central differential workflow: working stock vs failing Lineage.
- `vendor-blob-analysis` — proprietary blobs, linker dependencies, extraction and fixups.
- `hal-vintf-debug` — AIDL/HIDL services, manifests, matrices and registration failures.
- `selinux-bringup` — evidence-driven SELinux debugging without blind `audit2allow` policy generation.
- `kernel-bringup` — drivers, GKI/vendor modules, DT/DTBO, firmware and kernel/userspace boundaries.
- `boot-bringup` — early boot, first-stage mount, ramdisks, fstab and boot sequencing.
- `hardware-bringup` — end-to-end feature bring-up across framework -> HAL -> kernel.
- `lineage-build-fix` — targeted Soong/Ninja/product/vendor/kernel/SELinux build triage.

The repository-level `AGENTS.md` defines the default engineering discipline: stock ROM is the reference implementation, changes must be evidence-backed and minimal, and security controls must not be weakened as a shortcut.

## Install selected upstream skills

```bash
chmod +x scripts/install-upstream-skills.sh
./scripts/install-upstream-skills.sh
```

The script installs selected skills from:

- `hyperb1iss/hyperdroid-skill`: Android/ADB, Android build, Fastboot and LineageOS.
- `rasy007/android-skills`: ADB toolkit and crash analyzer.
- `aihip/android-claude-code-skills`: APK analyzer.

They are installed with `upstream-*` directory names so their provenance is obvious and custom firmware skills remain separate.

## Suggested workspace layout

```text
workspace/
├── AGENTS.md
├── .agents/skills/
├── scripts/
├── lineage/                  # LineageOS source tree or links/worktrees to relevant projects
└── stock/
    ├── extracted/
    │   ├── system/
    │   ├── system_ext/
    │   ├── product/
    │   ├── vendor/
    │   ├── odm/
    │   ├── vendor_dlkm/
    │   └── system_dlkm/
    ├── boot/
    │   ├── boot/
    │   ├── vendor_boot/
    │   ├── init_boot/
    │   ├── dtb/
    │   └── dtbo/
    └── runtime/
        ├── getprop.txt
        ├── logcat.txt
        ├── dmesg.txt
        ├── lshal.txt
        ├── service-list.txt
        └── dumpsys/
```

Large stock firmware images and extracted binaries generally should not be committed to this helper repository. Keep them locally or in dedicated storage and point Codex at the paths.

## Example tasks for Codex

```text
Wi-Fi works on stock but cannot be enabled on Lineage.
Use stock as the reference implementation. Trace the failure from framework/service through HAL, vendor configuration and kernel/firmware. Compare only relevant stock vs Lineage state, identify the root cause, and propose the smallest patch plus verification steps.
```

```text
Camera provider does not register on Lineage. Compare the stock camera provider service, VINTF declaration, init rc, shared-library dependencies, SELinux labels and related properties against our device/vendor tree. Do not add policy or blobs until the failing layer is identified.
```
