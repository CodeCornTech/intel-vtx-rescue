# Contributing

Compatibility evidence is the most useful contribution. Open the compatibility issue form with the board/revision, full BIOS version, CPU, Windows version, ITK tool/package version, a sanitized virtualization token block, the install exit code, the restart/power-cycle method and post-boot Windows status.

One report supports one tested configuration. Do not add a broad chipset-wide bypass or remove firmware guards to make an unsupported board pass. A compatibility expansion should include an independent successful record, token identity/options validation and offline rejection tests for mismatched settings. Never guess a token ID or value.

Run `tests/Test-Offline.ps1` and parse-check modified PowerShell scripts. Tests must not invoke ITK, write MSRs, flash firmware or restart the test machine. Keep Windows PowerShell 5.1 compatibility.

The first release's hardware record covers the manual procedure, not a hardware run of the wrappers. Mark wrapper validation separately when someone performs it.

Use small pull requests with a concrete problem, resulting behavior and validation. Do not commit full exports, original CPU-Z reports, serial numbers, usernames, passwords, remote-access credentials, Intel executables or VM disks. Reports should include only the relevant setting block and sanitized metadata.

A restoration file is a record of a prior setting, not a full BIOS image or an unconditional recovery guarantee.
