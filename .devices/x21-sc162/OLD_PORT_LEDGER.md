# Old Lineage/GSI port ledger

Source of truth for the late port history is `C:/Carlinkit_phh_v313/`. `D:/carlinkit/Carlinkit_aosp11/` contains the earlier branch and control experiments.

## Classification gate
Before proposing that any historical fix be carried into a new port, classify it as exactly one primary class:

1. `hardware-oem` — required by X21-SC162 hardware or Carlinkit/OEM integration.
2. `qualcomm-vendor` — required to initialize/use the SM6350 Qualcomm vendor stack.
3. `gsi-compat` — compensates for PHH/GSI/Lineage userspace behavior and must not be presumed necessary on another base.
4. `diagnostic-workaround` — logging, guards, forced settings, temporary recovery or experiment; never promote to production without new evidence.
5. `unknown` — evidence is insufficient; investigate before transfer.

A fix may mention secondary influences, but transfer decisions are based on the primary class and current evidence.

## Evidence levels
- `file`: implementation is present in a preserved artifact/script.
- `diagnostic`: behavior is supported by preserved logs/reports.
- `user-result`: observed result is recorded from the historical test but the complete artifact/diff may be missing.
- `hypothesis`: plausible explanation only; do not treat as root cause.

## Control points

| Build | Area | Evidence-backed result | Primary class | Transfer guidance |
| --- | --- | --- | --- | --- |
| r30 | CE lifecycle / OEM UI | MainAiBox startup was delayed until boot complete and CE storage availability after user-data preparation failures | gsi-compat | Do not transfer automatically to DUDU/modern base |
| r31 | Wi-Fi | restored `second_wifi.sh` and `second_wifi` init path loading `qca_cld3_wlan.ko`; Wi-Fi then worked | qualcomm-vendor | Preserve the equivalent working OEM/vendor initialization chain; do not duplicate DUDU loader |
| r31 | identity/activation | hardware serial was restored into GSI-visible identity through PHH resetprop behavior | gsi-compat | Do not spoof identity unless the new base demonstrably breaks OEM identity |
| r31 | LED JNI | restored `libcarsyso_serial_port.so`, but LED still did not work | hardware-oem | Dependency evidence only; insufficient as standalone fix |
| r32 | LED | restored LED scripts, services and compatible native component; LED worked before HUR and from OEM app | hardware-oem | Use as dependency map; compare DUDU's native implementation before reusing donor binary |
| r32 | OEM BT attempt | A11 `sdsdk816`, OEM event startup, UART/PTY access | hardware-oem | Historical attempt only; r32 did not close BT |
| r34-r35 | CP/AA/ADB | restored stock-style mode selection rather than permanently forcing AA/ADB; reverse.ini/code path worked in tests | hardware-oem | Preserve OEM mode lifecycle; exact minimal historical delta remains incomplete |
| r53 | OEM BT | `sdsdk816`, `/dev/goc_serial`, `com.carsyso.bluetooth`; pairing and contacts worked | hardware-oem | Strong reference point for transport/contacts, not proof of complete BT |
| r54 | call-log parser | parser changed for observed PD-framed call-log data; CP->AA switching regressed | diagnostic-workaround | Root-cause clue, not a transferable finished patch |
| r55-r56 | touch/storage/network ADB | physical touch, browser, microSD and Wi-Fi ADB were confirmed across these iterations | hardware-oem | Recover exact deltas where artifacts permit; do not collapse touch and overlay permission issues |
| r58 | permission dialogs | overlay policy blocked PermissionController interaction; policy adjustment restored dialog touch | gsi-compat | Treat as userspace overlay-policy compatibility issue |
| r58 | ordinary audio | controller configured AFE loopback and `RX_CDC_DMA_RX_0`; ordinary audio worked | diagnostic-workaround | Historical working state, not an SM6350 hardware constant |
| r74 | audio policy | PHH hid `/vendor/etc/audio` behind an empty mount; restoring policy visibility fixed the prior output-open failure | gsi-compat | Do not reproduce on a base that does not create the PHH mount |
| r74 | LTE | active subscription was queried rather than relying on one global Settings value; LTE state was observed | gsi-compat | Concept is useful; old Binder transaction IDs/settings are not portable |
| r74/r77 | audio initializer | `r69_audio_control.sh` checked policy and applied mixer setup; workable but tolerated individual tinymix failures | diagnostic-workaround | Technical-debt workaround; use only as comparative evidence |
| r77 | init cleanup | removed obsolete diagnostic scripts/services while retaining historical init structure | diagnostic-workaround | Port maintenance, not hardware enablement |
| r88 | audio rollback | removed r87 preready/control experiment and restored r69 audio control from r77; sound returned | diagnostic-workaround | Strong regression evidence, not a new hardware implementation |
| r88f | vendor audio experiment | patched `AFE_LOOPBACK_TX Port` from `None` to `RX_CDC_DMA_RX_0` | diagnostic-workaround | Reproducible experiment only; route later changed dynamically |
| r88g | defaults/diagnostics | requested 60 fps, event-driven stop of `vendor.cnss_diag`, volume defaults | diagnostic-workaround | 60 fps was not achieved; cnss_diag remains an optimization candidate, not a bring-up fix |

## Bluetooth protocol clue
Historical analysis of the r53/r54 call-log path described 473 observed frames shaped as `PD + type + UTF-8 name + 0xFF + number`, differing from the parser expectation in the selected APK branch. This is evidence for protocol/parser investigation, not proof that the r54 APK modification is safe: r54/r54b also coincided with a CP->AA regression whose causal chain was not closed.

## Audio conclusions
- Separate general playback, CP/AA media, BT media, call downlink and microphone/uplink.
- `RX_CDC_DMA_RX_0` is not an established hardware constant.
- r74 proves at least one major audio failure came from PHH/GSI policy visibility rather than the hardware/HAL itself.
- r88 proves rollback from a newer audio experiment could restore sound.
- r88f/r88g observations show route changes can be dynamic; route changes alone are not proof of failure.
- PCM read errors were real in late diagnostics, while compressed-offload causality was not established.

## Bluetooth conclusions
- r53 is the best preserved functional reference for OEM BT transport plus contacts.
- Pairing and contacts do not establish working call audio, call history or long-term stability.
- The call-log framing mismatch is concrete evidence, but the attempted parser patch is not a validated production fix.
- Compare DUDU's native `sdsdk816`/bridge/OEM APK environment before carrying A11 shims or patched APKs forward.

## Transfer rule
A historical fix is eligible for a modern-port proposal only when:
1. the current failure is reproduced,
2. the same dependency or mismatch is demonstrated on the current base,
3. DUDU/stock comparison supports the mechanism,
4. the proposed change is the smallest fix for that demonstrated mismatch.

Never transfer a fix merely because it appeared in a historically successful build.