<# Read-only Windows firmware virtualization status. No BIOS/MSR writes. #>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
if ($env:OS -ne 'Windows_NT') { throw 'This check requires Windows.' }
Get-CimInstance Win32_Processor -ErrorAction Stop |
    Select-Object Name, VirtualizationFirmwareEnabled, VMMonitorModeExtensions
