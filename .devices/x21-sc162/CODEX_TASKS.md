# Initial Codex task queue

Run these in order once local evidence is accessible.

## Task 1 — Reconstruct the old port
Analyze `D:/carlinkit/Carlinkit_aosp11/` and populate `evidence/x21-sc162/history/old-port-fix-ledger.md`.

Do not modify firmware. First produce evidence and a chronology of known-good/regressed builds.

## Task 2 — Establish DUDU baseline
Analyze `D:/carlinkit/DUDU_stock_opt/2608121631_2608120956` and document:
- partition/image hashes and formats
- system/vendor generation split
- init services
- VINTF declarations
- relevant vendor/ODM binaries and libraries
- kernel modules/firmware inventory

Respect the rule that `04_files` is not authoritative for Linux metadata.

## Task 3 — CP/AA map
Populate `evidence/x21-sc162/subsystems/cpaa-map.md` by correlating old-port modifications with DUDU OEM services, libraries, properties and runtime evidence.

## Task 4 — Audio regression
Find the last old Lineage build with working ordinary audio and the first regressed build. Produce a focused diff and root-cause hypotheses before proposing changes.

## Task 5 — OEM Bluetooth map
Recover the modifications that enabled pairing and contacts. Map the DUDU implementation and separate pairing, contacts, call control, call audio, microphone and stability paths.

## Deliverable rule
Every task should distinguish observed facts, inferred relationships and unresolved questions. Do not silently promote inference into fact.