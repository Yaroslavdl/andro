# LTE / radio dependency map

## Known evidence
Previous successful Lineage builds had working LTE. Full IMS/VoLTE validation was not completed.

## Keep separate
- modem/radio initialization
- SIM detection
- cellular registration
- packet data
- SMS/voice if applicable
- IMS/VoLTE

A working LTE data connection is not proof that IMS or voice calling works.

## Dependency chain to resolve
`Telephony framework -> radio service/HAL -> vendor RIL/daemon -> modem interfaces -> kernel transport -> modem firmware/config`

## First priority
Recover the exact old-port changes needed for LTE data and classify them as vendor compatibility, OEM integration, or GSI-specific workarounds.