# Intel VT-x Rescue

**Enable Intel VT-x from Windows without entering BIOS Setup.**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](scripts/Set-IntelVtx.ps1)
[![Verified platform](https://img.shields.io/badge/Verified-DH61CR%20BIOS%200038-green.svg)](docs/verified-case.md)

[Italiano](README.it.md) · [Verified case](docs/verified-case.md) · [Remote access](docs/remote-access.md) · [Sources](docs/sources.md)

VirtualBox reports `VERR_VMX_MSR_ALL_VMX_DISABLED`. The processor supports VT-x, but firmware has disabled it. On an Intel DH61CR with BIOS 0038, Intel's archived **Integrator Toolkit Legacy** successfully exported the setting, accepted a one-token change from Windows 11, and enabled VT-x after a normal restart.

```text
Before: VirtualizationFirmwareEnabled = False
ITK:    Component install succeeded. Exit code 0.
After:  VirtualizationFirmwareEnabled = True
```

This repository turns that recorded procedure into a documented workflow with original exports, a minimal change file, a restore file, and an explicit write flag. **The manual procedure was verified on the machine below. The reusable scripts have offline tests; they have not yet been independently tested on that hardware.**

## Verified scope

| Component | Recorded configuration |
| --- | --- |
| Motherboard | Intel DH61CR, revision AAG14064-207 |
| BIOS | BEH6110H.86A.0038.2012.0110.1653 |
| Processor | Intel Core i5-2400 |
| Host OS | Windows 11 Pro x64 |
| Intel package | ITK 5.0.4.575, containing Legacy components |
| Command-line tool | ITOOLKITW 1.4.1.135, package 5.0.4 |
| Exported token | SETTING_012F, 0 = Disable, 1 = Enable |
| Restart outcome | Normal Windows restart was sufficient in this case |
| CPU activation check | VirtualizationFirmwareEnabled = True |

The write script deliberately restricts itself to this board, exact BIOS and CPU. Other platforms need separate evidence and a reviewed compatibility change. Do not reuse `SETTING_012F` just because another computer also has Intel silicon.

## What this solves

- Enables the firmware VT-x setting on the recorded platform.
- Exports real BIOS tokens instead of guessing a setting identifier.
- Writes only one token; keeps the original export and a minimal restore file.
- Leaves restarting under your control.

It does not repair missing/corrupt VDI files, recover an XP installation, reset BIOS passwords, unlock a running CPU's locked MSR, or flash a new BIOS.

## Requirements

1. The verified Intel platform above for setting writes.
2. Windows PowerShell 5.1 or PowerShell 7, opened as Administrator.
3. The installed Intel Integrator Toolkit Legacy `itoolkitw.exe` and its companion files. Obtain the archived package through the [Intel Community thread](https://community.intel.com/t5/Mobile-and-Desktop-Processors/Modificar-a-tela-inicial-do-DH61AG-usando-Intel-Integrator/m-p/1654735). Intel binaries are not bundled here.

The Legacy documentation does not list Windows 11 as a supported OS. This is a recorded working case, not a claim of vendor support for Windows 11. Newer `VCUSTW` instructions are not interchangeable with the H61 Legacy tool.

## Quick start

Download/extract this repository on the Windows host. Run these commands in Administrator PowerShell **from the repository directory**, after inspecting the scripts. If downloaded files are marked as blocked, review them before unblocking; this project does not change execution policy or driver-security settings.

### 1. Inspect Windows status

```powershell
.\scripts\Test-IntelVtx.ps1
```

### 2. Read the actual firmware tokens

```powershell
.\scripts\Export-IntelVtxSettings.ps1
```

The export and log go to a unique directory under `C:\ProgramData\IntelVtxRescue`. An explicit `-ToolPath 'C:\path\to\itoolkitw.exe'` resolves missing or multiple installations.

### 3. Prepare a change without writing firmware

```powershell
.\scripts\Set-IntelVtx.ps1
```

This checks the platform, exports the original settings, validates the token's name/options/value, and prepares `change.ini`, `restore.ini`, and `operation.json`. It performs no setting install.

The prepared change has only the source INI version and the VT-x value:

```ini
[System]
INIversion=2.9

[SETTING_012F]
Value=1
```

### 4. Apply deliberately

```powershell
.\scripts\Set-IntelVtx.ps1 -Apply
```

This makes a fresh backup and invokes `ITOOLKITW INSTALL -tokens`. It does not change Lock/Hide attributes or invoke FLASH, REMOVE, shutdown or restart. Exit code 0 means ITK accepted the write; it does not prove that the CPU is already using VT-x.

### 5. Restart and verify

Read [remote-access.md](docs/remote-access.md) before restarting an unattended machine. A firmware confirmation can interrupt remote access. In the recorded case a normal restart worked:

```powershell
shutdown /r /t 0
```

After Windows returns:

```powershell
.\scripts\Test-IntelVtx.ps1
```

Look for `VirtualizationFirmwareEnabled = True`. Then retry your existing VM. If it stays False, do not keep modifying tokens: inspect the recorded export and plan any required power cycle with a verified way to regain access.

## Restore the previous setting

Each operation saves `restore.ini` with the value read before that operation. Inspect this file and its matching `operation.json` first. From the installed tool's own directory, run:

```powershell
.\itoolkitw.exe INSTALL -tokens '-ini=C:\ProgramData\IntelVtxRescue\YOUR_OPERATION\restore.ini'
```

A restore write has the same firmware-policy and restart considerations as the original write. To deliberately disable VT-x on the verified platform, the wrapper also accepts `-State Disable -Apply` and backs up its starting value.

## How it works

`MSR 0x3A` (`IA32_FEATURE_CONTROL`) was `0x1` before the change: bit 0 locked further register writes, while the VMX enable bits were clear. A Windows driver cannot simply flip the enable bit in that already-locked register. ITK changes the firmware setting used to initialize virtualization at a subsequent suitable boot.

The original export identified `[SETTING_012F]` as Intel Virtualization Technology, with `Value=0`. The tested change installed only `Value=1`. Intel documents a power-cycle requirement for VT-x and a configurable physical-presence policy for ITK; the successful ordinary restart is an observation for this exact machine, not a universal reset guarantee. See [sources](docs/sources.md).

## Tests and contributions

```powershell
.\tests\Test-Offline.ps1
```

Offline tests reject ambiguous tokens, duplicate values, reversed options and unverified firmware. CI parses every PowerShell script and runs the tests under Windows PowerShell and PowerShell 7. No CI job invokes ITK or modifies firmware.

Have another verified board/BIOS combination? Open a compatibility report with the exact versions, a sanitized token block, install exit code, restart method and post-boot status. Keep serial numbers, usernames, full BIOS exports, binary installers and VM disks out of public reports. See [CONTRIBUTING.md](CONTRIBUTING.md).

If this saved you a BIOS visit, **give the project a star**. A precise compatibility report is even more useful.

## License and credits

Original project scripts and documentation: [MIT](LICENSE), CodeCorn Technology. Intel Integrator Toolkit and its documentation retain their own terms. Intel and VirtualBox names belong to their respective owners; this project is independent and is not endorsed by them.
