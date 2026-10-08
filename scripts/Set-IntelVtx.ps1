<# Default: export and prepare files only. -Apply explicitly enables a firmware setting write. #>
[CmdletBinding()]
param(
    [ValidateSet('Enable','Disable')][string]$State = 'Enable',
    [switch]$Apply,
    [string]$ToolPath,
    [string]$BackupRoot
)
$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'IntelVtx.Common.ps1')
Assert-IntelVtxWindowsAdmin
$machine = Get-IntelVtxMachine
Assert-IntelVtxSupportedMachine -Machine $machine
$tool = Find-IntelVtxTool -ToolPath $ToolPath
$folder = New-IntelVtxBackupDirectory -BackupRoot $BackupRoot
$original = Join-Path $folder 'tokens-original.ini'
$log = Join-Path $folder 'export.log'
$code = Invoke-IntelVtxTool -ToolPath $tool -ToolArguments @('EXTRACT', '-tokens', "-ini=$original", "-log=$log")
if ($code -ne 0 -or -not (Test-Path -LiteralPath $original -PathType Leaf)) { throw "Export failed. Exit code: $code. Log: $log" }
$token = Get-IntelVtxToken -Text (Get-Content -LiteralPath $original -Raw)
$desired = 0
if ($State -eq 'Enable') { $desired = 1 }
$patch = Join-Path $folder 'change.ini'
$restore = Join-Path $folder 'restore.ini'
[IO.File]::WriteAllText($patch, (New-IntelVtxMinimalIni -Token $token -Value $desired), [Text.Encoding]::ASCII)
[IO.File]::WriteAllText($restore, (New-IntelVtxMinimalIni -Token $token -Value $token.Value), [Text.Encoding]::ASCII)
$record = [pscustomobject]@{
    Timestamp = (Get-Date).ToString('o')
    Machine = $machine
    ToolVersion = (Get-Item -LiteralPath $tool).VersionInfo.FileVersion
    Token = 'SETTING_012F'
    OriginalValue = $token.Value
    RequestedValue = $desired
    OriginalExportSHA256 = (Get-FileHash -LiteralPath $original -Algorithm SHA256).Hash
    PatchSHA256 = (Get-FileHash -LiteralPath $patch -Algorithm SHA256).Hash
    ApplyRequested = [bool]$Apply
}
$record | ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $folder 'operation.json') -Encoding UTF8
Write-Host "Original value: $($token.Value); requested value: $desired"
Write-Host "Backup and recovery files: $folder"
Get-Content -LiteralPath $patch | Out-Host
if ($token.Value -eq $desired) {
    Write-Host 'The exported firmware setting already has this value. No write performed.'
    return
}
if (-not $Apply) {
    Write-Host 'DRY RUN: files prepared; no firmware setting written. Use -Apply to write.'
    return
}
$installLog = Join-Path $folder 'install.log'
$code = Invoke-IntelVtxTool -ToolPath $tool -ToolArguments @('INSTALL', '-tokens', "-ini=$patch", "-log=$installLog")
if ($code -ne 0) { throw "ITK reported failure ($code). Settings may be partially processed: inspect $installLog. No reboot was requested." }
Write-Host 'ITK accepted the write. CPU activation is not yet verified.'
Write-Host 'No reboot was requested. Read docs/remote-access.md before restarting remotely.'
Write-Host 'After the next suitable boot, run scripts/Test-IntelVtx.ps1.'
