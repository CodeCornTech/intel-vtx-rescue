# Changelog

## 0.1.0 — 2026-10-08

- Recorded successful manual VT-x activation on DH61CR BIOS 0038 from Windows 11 using Intel ITK Legacy.
- Added read-only export/status scripts and a one-token write wrapper with a default preparation mode.
- Added original-setting restoration files, hashes and per-operation backups.
- Restricted wrapper writes to the exact recorded board, BIOS and CPU.
- Added offline parser/guard tests, Windows CI, English/Italian documentation and compatibility reporting.
- Added GitHub bootstrap and release notes. No Intel binary redistribution or automatic reboot.
