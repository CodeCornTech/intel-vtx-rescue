# Recorded DH61CR / BIOS 0038 case

Recorded on 2026-10-08. One machine, one successful manual procedure. Customer identifiers and filesystem paths have been removed.

## Starting evidence

- Intel DH61CR, AAG14064-207; Intel Core i5-2400.
- BIOS BEH6110H.86A.0038.2012.0110.1653.
- Windows 11 Pro x64; Windows status had reported virtualization disabled.
- CPU-Z enumerated VT-x capability, but reported MSR 0x3A = 0x1 on all four cores.
- VirtualBox reported VERR_VMX_MSR_ALL_VMX_DISABLED.

## Tool and export

The installed package was Intel ITK 5.0.4.575. Its Legacy Windows command-line component identified itself as:

```text
Intel(R) Integrator ToolkitW Version 1.4.1.135 (Package 5.0.4)
```

`ITOOLKITW EXTRACT -tokens` completed successfully. The relevant exported section contained:

```ini
[SETTING_012F]
; Intel Virtualization Technology
; 0 : Disable
; 1 : Enable
Value=0
Lock=FALSE
Hide=FALSE
```

The export's System section declared INIversion=2.9. Lock/Hide describe the setup setting's UI controls; their values do not prove that ITK's physical-presence policy is disabled.

## Applied change

The original export was preserved. A separate change file contained:

```ini
[System]
INIversion=2.9

[SETTING_012F]
Value=1
```

A corresponding restore file retained Value=0. The installed tool was run with `INSTALL -tokens -ini=<change file>` and a local log path. It returned:

```text
Now installing Component...
Component install succeeded.
Operation completed successfully.
Exit code: 0
```

## Boot and verification

No onsite person was available. The operator deliberately tried a normal Windows restart using `shutdown /r /t 0`. Remote access returned, and the post-boot command:

```powershell
Get-CimInstance Win32_Processor | Select-Object Name, VirtualizationFirmwareEnabled
```

reported the i5-2400 with `VirtualizationFirmwareEnabled = True`. No onsite confirmation was required in the reported sequence.

The CPU's MSR was not re-read after the change. Successful boot of the old guest VM and recovery of its disk were not established; those are distinct problems. Do not interpret the record as evidence that the guest installation was recovered.

The repository wrappers were written after this manual success. Their parser and guards are tested offline, not yet validated by a second hardware run.
