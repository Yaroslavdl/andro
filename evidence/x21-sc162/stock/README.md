# DUDU stock evidence

Primary reference build: `2608121631_2608120956`.

Generate the first safe inventories locally with:

```powershell
powershell -ExecutionPolicy Bypass -File scripts/collect-dudu-baseline.ps1
```

Expected generated reports:
- `image-files.tsv`
- `image-sha256.tsv`
- `analysis-files.tsv`
- `live-log-files.tsv`

Review outputs before committing. The Windows-extracted `04_files/new` inventory is useful for path/content discovery but is not authoritative for Linux filesystem metadata.