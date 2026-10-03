# Partition evidence

## Confirmed DUDU OTA images
Recorded under `03_images/`:
- boot.img
- recovery.img
- dtbo.img
- system.img
- system_ext.img
- product.img
- vendor.img
- odm.img
- vbmeta.img
- vbmeta_system.img

No separate `vendor_boot.img` or `vendor_dlkm.img` is present in the currently documented OTA extraction.

## Generation split
| Partition group | Android generation |
| --- | --- |
| system / system_ext / product | Android 15 / SDK 35 |
| vendor / odm | Android 11 / SDK 30 |
| kernel | 4.19.157-perf |
| first API level | 30 |

## Investigation tasks
Do not assume the list above is the complete physical partition table. When local evidence is available, record:
- `fastboot getvar all` where supported
- `/dev/block/by-name` and resolved block devices
- dynamic partition / super metadata
- filesystem types and image formats
- A/B slot behavior
- boot header version and ramdisk layout
- whether vendor ramdisk content is embedded or otherwise absent due to this platform's boot architecture
- DTB location and DTBO entries
- AVB chain and descriptors

## Metadata authority
For permissions, symlinks, labels, capabilities and xattrs, use original images or live-device collection. `04_files/` is not authoritative for these fields.