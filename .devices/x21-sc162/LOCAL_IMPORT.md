# Local evidence import checklist

When access to `D:/carlinkit/...` is available, do not upload entire stock images or proprietary firmware to this public repository by default.

Instead generate and commit sanitized textual reports, manifests, hashes and project-authored scripts where appropriate.

## First directory to analyze
`D:/carlinkit/Carlinkit_aosp11/`

Goal: reconstruct the previous port history and produce a fix ledger.

Collect:
- directory/file inventory with timestamps and sizes
- build and patch scripts
- text configs and project notes
- checksums/names of GSI and stock artifacts
- diffs between known-good and later builds where reconstructable
- diagnostic logs tied to builds

## DUDU reference workspace
`D:/carlinkit/DUDU_stock_opt/2608121631_2608120956`

Generate reports for:
- partition image metadata and hashes
- filesystem manifests from authoritative extraction
- init service inventory
- VINTF inventory
- property inventory
- HAL/service inventory
- vendor/ODM executable and shared-library inventory
- kernel modules and firmware inventory
- audio/Bluetooth/telephony-related file inventory

## Public repository hygiene
Before committing generated evidence:
- exclude proprietary binary payloads unless explicitly intended and legally appropriate
- exclude credentials, tokens, device identifiers and personal data from logs
- prefer hashes + paths + metadata over binary copies
- redact Wi-Fi SSIDs, phone numbers, contacts, account identifiers, IPs when not needed
- keep raw sensitive logs local and commit only sanitized extracts/reports

## Recommended generated report tree
`evidence/x21-sc162/`
- `history/old-port-fix-ledger.md`
- `stock/dudu-build-summary.md`
- `stock/partition-manifest.tsv`
- `stock/init-services.tsv`
- `stock/vintf-summary.md`
- `stock/vendor-files.tsv`
- `runtime/dudu-services.txt`
- `runtime/dudu-properties-sanitized.txt`
- `runtime/dudu-modules.txt`
- `subsystems/audio-map.md`
- `subsystems/bluetooth-map.md`
- `subsystems/cpaa-map.md`
