# Offline parser and write-boundary tests. Never invokes ITK or reads real hardware.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
. (Join-Path $root 'scripts/IntelVtx.Common.ps1')
$fixture = Get-Content -LiteralPath (Join-Path $root 'examples/dh61cr-0038-original.synthetic.ini') -Raw
$script:passed = 0
function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
    $script:passed++
}
function Assert-Rejected([scriptblock]$Action, [string]$Message) {
    $rejected = $false
    try { & $Action | Out-Null } catch { $rejected = $true }
    Assert-True $rejected $Message
}
foreach ($text in @($fixture, ($fixture -replace "`r?`n", "`r`n"))) {
    $token = Get-IntelVtxToken -Text $text
    Assert-True ($token.Value -eq 0 -and $token.INIVersion -eq '2.9') 'Failed to read original token.'
    $patch = New-IntelVtxMinimalIni -Token $token -Value 1
    Assert-True ($patch -match 'Value=1' -and $patch -notmatch 'SETTING_00A5|Lock=|Hide=') 'Patch includes unrelated settings or UI attributes.'
    $sections = @([regex]::Matches($patch, '(?m)^\['))
    Assert-True ($sections.Count -eq 2) 'Patch must contain only System and the VT-x token.'
    $restore = New-IntelVtxMinimalIni -Token $token -Value $token.Value
    Assert-True ($restore -match 'Value=0') 'Restore must preserve the original value.'
}
Assert-Rejected { Get-IntelVtxToken -Text ($fixture + "`n[SETTING_012F]`nValue=1`n") } 'Duplicate token accepted.'
Assert-Rejected { Get-IntelVtxToken -Text ($fixture -replace 'Value=0', "Value=0`nValue=1") } 'Duplicate value accepted.'
Assert-Rejected { Get-IntelVtxToken -Text ($fixture -replace 'Virtualization Technology', 'Unrelated setting') } 'Wrong token identity accepted.'
Assert-Rejected { Get-IntelVtxToken -Text ($fixture -replace '0 : Disable', '0 : Enable') } 'Reversed options accepted.'
Assert-Rejected { Get-IntelVtxToken -Text ($fixture -replace 'Value=0', 'Value=9') } 'Invalid value accepted.'
Assert-Rejected { Get-IntelVtxToken -Text ($fixture -replace 'INIversion=2.9', '') } 'Missing version accepted.'
$machine = [pscustomobject]@{ BoardManufacturer='Intel Corporation'; Board='DH61CR'; BIOS='BEH6110H.86A.0038.2012.0110.1653'; CPU='Intel(R) Core(TM) i5-2400 CPU' }
Assert-IntelVtxSupportedMachine -Machine $machine
$machine.BIOS = 'BEH6110H.86A.0099'
Assert-Rejected { Assert-IntelVtxSupportedMachine -Machine $machine } 'Unverified BIOS accepted.'
$machine.BIOS = 'BEH6110H.86A.0038.2012.0110.1653'
$machine.Board = 'DH61AG'
Assert-Rejected { Assert-IntelVtxSupportedMachine -Machine $machine } 'Unverified board accepted.'
$setScript = Join-Path $root 'scripts/Set-IntelVtx.ps1'
$tokens = $null; $parseErrors = $null
$ast = [Management.Automation.Language.Parser]::ParseFile($setScript, [ref]$tokens, [ref]$parseErrors)
Assert-True ($parseErrors.Count -eq 0) 'Set script syntax is invalid.'
$calls = @($ast.FindAll({ param($node) $node -is [Management.Automation.Language.CommandAst] }, $true))
Assert-True (-not @($calls | Where-Object { $_.GetCommandName() -match '^(Restart-Computer|Stop-Computer|shutdown(?:\.exe)?)$' }).Count) 'Hardware script requests a reboot/shutdown.'
Write-Host "PASS: $script:passed offline assertions. No firmware operations executed."
