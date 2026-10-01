# Wi-Fi dependency map

## Known evidence
- DUDU: working.
- Previous successful Lineage builds: working.

## Chain to resolve
`framework Wi-Fi -> service/HAL -> vendor implementation -> kernel driver/module -> firmware/calibration -> hardware`

## Recovery goal
Because Wi-Fi already worked in old Lineage, recover the minimal historical fix set first. Determine whether success depended on:
- vendor blobs
- firmware paths
- kernel modules
- properties
- init services
- permissions/SELinux
- GSI-specific compatibility settings

Use DUDU as the modern-system reference and old Lineage as proof of what the project already solved.