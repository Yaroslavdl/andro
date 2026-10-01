# Historical port evidence

This directory is for sanitized, textual evidence recovered from the previous `Carlinkit_aosp11` work.

First generate an inventory locally:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/collect-x21-history.ps1
```

Then review `file-inventory.tsv` and `text-candidates.txt` before committing them.

Do not commit raw proprietary images, private logs, credentials, contacts, phone numbers, account identifiers or other unnecessary device/user data.

The primary analysis deliverable will be `old-port-fix-ledger.md`, mapping every historical modification to a subsystem, observed effect, evidence and modern-port relevance.