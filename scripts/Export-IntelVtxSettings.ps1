<# Read-only firmware export. Does not install settings or restart Windows. #>
[CmdletBinding()]
param([string]$ToolPath, [string]$BackupRoot)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'IntelVtx.Common.ps1')
Assert-IntelVtxWindowsAdmin
$tool = Find-IntelVtxTool -ToolPath $ToolPath
$folder = New-IntelVtxBackupDirectory -BackupRoot $BackupRoot
$ini = Join-Path $folder 'tokens-original.ini'
$log = Join-Path $folder 'export.log'
$machine = Get-IntelVtxMachine
$machine | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $folder 'machine.json') -Encoding UTF8
$code = Invoke-IntelVtxTool -ToolPath $tool -ToolArguments @('EXTRACT', '-tokens', "-ini=$ini", "-log=$log")
if ($code -ne 0 -or -not (Test-Path -LiteralPath $ini -PathType Leaf)) { throw "Export failed. Exit code: $code. Log: $log" }
Write-Host "Original export: $ini"
Select-String -LiteralPath $ini -Pattern 'Virtualization|Unattended' -Context 2,12
