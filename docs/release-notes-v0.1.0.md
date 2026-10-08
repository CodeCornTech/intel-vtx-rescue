# Intel VT-x Rescue 0.1.0

Enable Intel VT-x from Windows with Intel ITK Legacy: a recorded working procedure for DH61CR BIOS 0038, with original exports and a one-token change.

The observed host moved from virtualization disabled to `VirtualizationFirmwareEnabled = True` after a normal Windows restart. The repository adds export/status helpers, explicit write mode, a restore file, exact platform guards, offline tests and English/Italian documentation.

The manual procedure is hardware-verified on one host. The reusable wrappers are validated offline; they still need an independent hardware run. Other boards and BIOS versions are not supported for writes yet. Intel binaries are not included. This does not recover guest VM disks or Windows XP installations.

Please contribute sanitized compatibility evidence. If this saved a BIOS visit, a star helps others discover it.
