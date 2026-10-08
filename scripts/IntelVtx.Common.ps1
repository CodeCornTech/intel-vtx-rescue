function Assert-IntelVtxWindowsAdmin {
    if ($env:OS -ne 'Windows_NT') { throw 'Hardware operations require Windows.' }
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Open PowerShell as Administrator.'
    }
}

function Find-IntelVtxTool {
    param([string]$ToolPath)
    if ($ToolPath) {
        $file = Get-Item -LiteralPath $ToolPath -ErrorAction Stop
        if ($file.PSIsContainer -or $file.Name -ine 'itoolkitw.exe') {
            throw 'ToolPath must point to the installed Legacy itoolkitw.exe.'
        }
        return $file.FullName
    }
    $candidates = @(
        foreach ($root in @($env:ProgramFiles, ${env:ProgramFiles(x86)})) {
            if ($root -and (Test-Path -LiteralPath $root)) {
                Get-ChildItem -LiteralPath $root -Filter 'itoolkitw.exe' -Recurse -File -ErrorAction SilentlyContinue
            }
        }
    )
    if ($candidates.Count -ne 1) {
        throw "Found $($candidates.Count) tools. Supply -ToolPath with the installed Legacy executable."
    }
    return $candidates[0].FullName
}

function Get-IntelVtxMachine {
    $boards = @(Get-CimInstance Win32_BaseBoard -ErrorAction Stop)
    $bioses = @(Get-CimInstance Win32_BIOS -ErrorAction Stop)
    $cpus = @(Get-CimInstance Win32_Processor -ErrorAction Stop)
    if ($boards.Count -ne 1 -or $bioses.Count -ne 1 -or $cpus.Count -ne 1) {
        throw 'Expected one motherboard, BIOS and processor socket.'
    }
    [pscustomobject]@{
        BoardManufacturer = [string]$boards[0].Manufacturer
        Board = [string]$boards[0].Product
        BIOS = [string]$bioses[0].SMBIOSBIOSVersion
        CPU = [string]$cpus[0].Name
        VirtualizationFirmwareEnabled = $cpus[0].VirtualizationFirmwareEnabled
    }
}

function Assert-IntelVtxSupportedMachine {
    param([object]$Machine)
    if ($Machine.BoardManufacturer.Trim() -ine 'Intel Corporation' -or
        $Machine.Board.Trim() -ine 'DH61CR' -or
        $Machine.BIOS.Trim() -ine 'BEH6110H.86A.0038.2012.0110.1653' -or
        $Machine.CPU -notmatch 'Intel.*i5-2400') {
        throw 'Writes are restricted to the recorded DH61CR / BIOS 0038 / i5-2400 configuration. No firmware setting was written.'
    }
}

function Get-IntelVtxToken {
    param([Parameter(Mandatory=$true)][string]$Text)
    $headers = [regex]::Matches($Text, '(?im)^[ \t]*\[SETTING_012F\][ \t]*\r?$')
    $systems = [regex]::Matches($Text, '(?im)^[ \t]*\[System\][ \t]*\r?$')
    if ($headers.Count -ne 1 -or $systems.Count -ne 1) {
        throw 'Missing or duplicate System / SETTING_012F sections.'
    }
    $system = [regex]::Match($Text, '(?ims)^[ \t]*\[System\][ \t]*\r?\n.*?(?=^[ \t]*\[|\z)')
    $token = [regex]::Match($Text, '(?ims)^[ \t]*\[SETTING_012F\][ \t]*\r?\n.*?(?=^[ \t]*\[|\z)')
    $versions = [regex]::Matches($system.Value, '(?im)^[ \t]*INIversion[ \t]*=[ \t]*([0-9]+(?:\.[0-9]+)*)[ \t]*\r?$')
    $values = [regex]::Matches($token.Value, '(?im)^[ \t]*Value[ \t]*=[ \t]*([01])[ \t]*\r?$')
    $allValueKeys = [regex]::Matches($token.Value, '(?im)^[ \t]*Value[ \t]*=')
    if ($versions.Count -ne 1 -or $values.Count -ne 1 -or $allValueKeys.Count -ne 1 -or
        $token.Value -notmatch 'Intel[^\r\n]*Virtualization Technology' -or
        $token.Value -notmatch '(?im)^[ \t]*;[ \t]*0[ \t]*:[ \t]*Disable[ \t]*\r?$' -or
        $token.Value -notmatch '(?im)^[ \t]*;[ \t]*1[ \t]*:[ \t]*Enable[ \t]*\r?$') {
        throw 'VT-x token identity, options, value or INI version do not match the recorded export.'
    }
    [pscustomobject]@{
        INIVersion = $versions[0].Groups[1].Value
        Value = [int]$values[0].Groups[1].Value
    }
}

function New-IntelVtxMinimalIni {
    param([Parameter(Mandatory=$true)][object]$Token, [ValidateSet(0,1)][int]$Value)
    if ([string]$Token.INIVersion -notmatch '^[0-9]+(?:\.[0-9]+)*$') { throw 'Invalid INI version.' }
    "[System]`r`nINIversion=$($Token.INIVersion)`r`n`r`n[SETTING_012F]`r`nValue=$Value`r`n"
}

function Invoke-IntelVtxTool {
    param([string]$ToolPath, [string[]]$ToolArguments)
    Push-Location (Split-Path -Parent $ToolPath)
    try {
        # Preserve ITK output on the host; return only the native process exit code.
        & $ToolPath @ToolArguments | Out-Host
        return $LASTEXITCODE
    }
    finally { Pop-Location }
}

function New-IntelVtxBackupDirectory {
    param([string]$BackupRoot)
    if (-not $BackupRoot) { $BackupRoot = Join-Path $env:ProgramData 'IntelVtxRescue' }
    $folder = Join-Path $BackupRoot ((Get-Date -Format 'yyyyMMdd_HHmmss') + '_' + [guid]::NewGuid().ToString('N').Substring(0,8))
    New-Item -ItemType Directory -Path $folder -ErrorAction Stop | Out-Null
    return $folder
}
