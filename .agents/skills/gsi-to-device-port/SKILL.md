---
name: gsi-to-device-port
description: Use when recovering knowledge from the project's previous GSI-based Lineage/PHH experiments and converting successful binary patches, scripts and configuration into a maintainable X21-SC162 port strategy.
---

# GSI-to-device port recovery

The old Lineage 18.1 work was GSI-based and had no project-owned device/vendor/kernel source trees. Its artifacts are valuable experimental evidence, but historical success does not make every patch a hardware requirement.

## Historical roots
Use both trees with different roles:
- `C:/Carlinkit_phh_v313/` — primary source for the late PHH -> Lineage 18 history, including preserved r30/r31/r32 profiles, diagnostics for r33-r35/r53-r58/r74, r77 artifacts, and r88/r88f/r88g artifacts.
- `D:/carlinkit/Carlinkit_aosp11/` — earlier experiments and stock/control history.

The late history is incomplete. Missing artifacts must remain explicitly unknown rather than reconstructed from build numbers or assumptions.

## Mandatory classification gate
Before recommending transfer of any old fix, assign one primary class:
- `hardware-oem`: X21-SC162 hardware or Carlinkit/OEM integration requirement.
- `qualcomm-vendor`: required Qualcomm SM6350 vendor initialization/integration.
- `gsi-compat`: compensates for PHH/GSI/Lineage behavior.
- `diagnostic-workaround`: logger, guard, forced setting, experiment, rollback helper or temporary recovery mechanism.
- `unknown`: insufficient evidence.

Do not propose transfer until classification is complete.

## Evidence labels
For every ledger entry identify evidence as:
- file
- diagnostic
- user-result
- hypothesis

Never promote a hypothesis to a root cause merely because a later build worked.

## Build a fix ledger
For each discovered modification record:
- build/control point
- exact source artifact
- exact target artifact/path
- subsystem
- change
- observed effect
- evidence type
- primary classification
- analogous DUDU mechanism, if demonstrated
- whether the failure exists on the current base
- modern-port transfer decision

Use `.devices/x21-sc162/OLD_PORT_LEDGER.md` as the current evidence-backed summary.

## Known examples that constrain reasoning
- r31 Wi-Fi restored an OEM/Qualcomm module-loading path for `qca_cld3_wlan.ko`; preserve equivalent initialization rather than blindly copying the script.
- r74 audio failure involved a PHH mount hiding `/vendor/etc/audio`; this is GSI compatibility, not evidence of broken Qualcomm audio hardware.
- r53 OEM Bluetooth pairing/contacts is a useful functional reference, while r54 parser work regressed CP->AA and is not a finished patch.
- r88 sound returned after rollback to an older audio controller; r88f's static loopback route is an experiment, not a hardware constant.

## Transfer decision
A historical fix can become a modern-port candidate only if:
1. the current failure is reproduced,
2. the same dependency/mismatch is demonstrated,
3. stock/DUDU comparison supports the mechanism,
4. the proposed change is minimal.

## Desired output
Produce a migration map from historical binary/image patching toward maintainable source/config changes where possible. Preserve proprietary components only when current evidence shows they remain required. Explicitly reject obsolete PHH/GSI workarounds when their triggering condition does not exist.