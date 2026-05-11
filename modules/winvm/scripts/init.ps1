<# ===================================================================
  Cloud-init Bootstrap Script (two containers, idempotent)
  Maintainer : <your team / yourself>
  Version    : v1.29
  Date       : 2025-09-18

  NOTE: This script uses only ASCII characters.

  ---------------------------
  CHANGELOG
  ---------------------------
  v1.0   - Initial baseline (two-container layout)
           - Split storage into:
               packages/ : installers and binaries
               scripts/  : configs, .bgi, PowerShell scripts
           - Core setup: ICMP rule, RAW disk init
           - Installs: PowerShell 7, Az modules (zip), Azure CLI, AWS CLI,
                       7-Zip, Sysinternals, Windows Terminal, VS Code,
                       Storage Explorer, Azure Data Studio, MobaXterm, Postman
           - OpenSSH server + admin pubkey (from scripts container)
           - scheduled.ps1 at logon, optional SHIR
  v1.1   - Safe defaults and two-container enforcement
  v1.2   - Idempotency hardening
  v1.3   - Preinstall Az modules first (PS 5.1), enable MI login early
  v1.4   - Az module copy tolerant of in-use files
  v1.5   - Postman unattended improvements + syntax fixes
  v1.6   - Added Env parameter
  v1.7   - Unified temp workspace at C:\Temp\Bootstrap
  v1.8   - Postman duplicate shortcut cleanup (keep Public)
  v1.9   - OpenSSH key pulled from scripts container
  v1.10  - Simplified OpenSSH key name: "azureadmin-pubkey"
  v1.11  - Defender performance mode during heavy work
  v1.12  - Detailed timing logs per software step
  v1.13  - Logging clarity using "${step}: ..." pattern
  v1.14  - Readability: section separators; per-module TOTAL minutes
  v1.15  - Postman: removed portable fallback; MSI-only silent install
  v1.16  - Replaced robocopy with Copy-Item for local copies
  v1.17  - Braced variables before punctuation (e.g. ${Url}:) to avoid parsing issues
  v1.18  - Removed Start-BitsTransfer entirely; downloader is now:
           Invoke-WebRequest primary; WebClient fallback only
  v1.19  - StorageAccount is now a parameter (default: stccoeiacccnonprod);
           fixed extra parenthesis in Azure Arc cleanup if-statement
  v1.20  - Fixed remaining ${var}: bracing in logs (Path, Destination, Source)
  v1.21  - Windows Terminal submodule hardened for deps presence checks
  v1.22  - Managed Identity blob wildcard resolver for latest package selection
  v1.23  - IMPORTANT: For az-modules.zip, skip MI and fetch via direct HTTPS
           first to ensure Connect-AzAccount becomes available on PS 5.1
  v1.24  - Windows Server 2022 SYSTEM-safe Terminal install:
           use Add-AppxProvisionedPackage/DISM provisioning for XAML, VCLibs, Terminal
  v1.25  - Windows Terminal provisioning order changed:
           PREFER DISM first (SYSTEM-safe), then fallback to Add-AppxProvisionedPackage
  v1.26  - Added AzCopy installation
  v1.27  - Added SSMS installation for adf
  v1.28  - commented out SSMS installation for now until we have an offline package.
  v1.29  - Added new file download module using system Managed Identity directly via IMDS,
         without requiring Connect-AzAccount or Az modules. Functions:
         Get-AzStorageTokenMI, Download-FileMI, Get-PackageByWildcardMI, Get-ScriptExactMI.
  ---------------------------
  SUMMARY
  - Two-container model:
      packages/ : installers and binaries
      scripts/  : configs, .bgi, PowerShell scripts
  - Access:
      * For az-modules.zip: direct HTTPS first (no MI)
      * For all other installers: Managed Identity wildcard listing, else anon HTTP fallback
  - Run order (no parameters required):
      1) Download and install Az modules to PS 5.1 from az-modules.zip (HTTPS)
      2) Connect-AzAccount -Identity (if permitted)
      3) ICMP rule, RAW disk init
      4) Enter Defender perf mode -> Software installs -> Exit perf mode
      5) Copy Az modules to PS 7 after PS 7 install (keep extracted folder)
      6) OpenSSH + admin key, BGInfo, scheduled task, Arc cleanup, WinRM
      7) Optional SHIR
      8) Added AzCopy installation
=================================================================== #>

param(
    [switch]$EnableSHIR       = $false,
    [string]$LogFile          = 'C:\Logs\Init\InitLog.txt',
    [string]$AppRemoteGroup   = '',
    [string]$AppAdminGroup    = '',
    [string]$Env              = 'dev',
    [switch]$RebootWhenDone   = $false,
    [string]$StorageAccount   = 'stccoeiacccnonprod'
)

# ===================================================================
# Helpers (ASCII only)
# ===================================================================

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor 3072 } catch {}

# Unified temp workspace
$TempRoot = 'C:\Temp\Bootstrap'
$DlDir    = Join-Path $TempRoot 'dl'
$WorkDir  = Join-Path $TempRoot 'work'
$LogsDir  = Split-Path $LogFile -Parent

function Ensure-Directory {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}
Ensure-Directory -Path $TempRoot
Ensure-Directory -Path $DlDir
Ensure-Directory -Path $WorkDir
Ensure-Directory -Path $LogsDir

# Point TEMP/TMP to the unified workspace
$env:TEMP = $TempRoot
$env:TMP  = $TempRoot

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$ts - $Message"
}

function Format-Duration {
    param([TimeSpan]$ts)
    $total = [int]$ts.TotalSeconds
    $h = [int]($total/3600)
    $m = [int](($total%3600)/60)
    $s = $total%60
    return ("{0:00}h:{1:00}m:{2:00}s" -f $h,$m,$s)
}
function Format-Minutes {
    param([TimeSpan]$ts)
    return ("{0:N2}" -f $ts.TotalMinutes)
}

# Section separator
function Log-Section {
    param([string]$Title)
    Write-Log "----------------------------------------------------------------"
    Write-Log $Title
    Write-Log "----------------------------------------------------------------"
}

# Remove a file safely
function Remove-FileSafe {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (Test-Path -LiteralPath $Path) {
        try { Remove-Item -LiteralPath $Path -Force -ErrorAction Stop } catch { Write-Log "WARN: Could not remove ${Path}: $_" }
    }
}

# Fast resilient downloader (anon). IWR first, WebClient fallback.
function Download-File {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$Destination,
        [int]$MaxRetries = 3
    )
    Ensure-Directory -Path (Split-Path $Destination -Parent)
    Remove-FileSafe -Path $Destination

    $attempt = 0
    $lastErr = $null
    while ($attempt -lt $MaxRetries) {
        $attempt++
        try {
            $prevPP = $global:ProgressPreference
            try {
                $global:ProgressPreference = 'SilentlyContinue'
                Invoke-WebRequest -Uri $Url -OutFile $Destination -UseBasicParsing -ErrorAction Stop
            } finally {
                $global:ProgressPreference = $prevPP
            }
            if (Test-Path -LiteralPath $Destination) { return $true }
        } catch {
            $lastErr = $_
            Write-Log "WARN: IWR attempt $attempt failed for ${Url}: $lastErr"
            try {
                $wc = New-Object System.Net.WebClient
                $wc.DownloadFile($Url, $Destination)
                if (Test-Path -LiteralPath $Destination) { return $true }
            } catch {
                $lastErr = $_
                Write-Log "WARN: WebClient attempt $attempt failed for ${Url}: $lastErr"
            }
            Start-Sleep -Seconds (5 * $attempt)
        }
    }
    throw "Download failed for ${Url} after $MaxRetries attempts. Last error: $lastErr"
}

# Copy a folder with per-file try/catch, tolerate in-use/locked files
function Copy-FolderFast {
    param(
        [Parameter(Mandatory=$true)][string]$Source,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    Ensure-Directory -Path $Destination
    Get-ChildItem -LiteralPath $Source -Recurse -Force | ForEach-Object {
        $rel = $_.FullName.Substring($Source.Length).TrimStart('\')
        $target = Join-Path $Destination $rel
        if ($_.PSIsContainer) {
            Ensure-Directory -Path $target
        } else {
            Ensure-Directory -Path (Split-Path $target -Parent)
            try {
                Copy-Item -LiteralPath $_.FullName -Destination $target -Force -ErrorAction Stop
            } catch {
                $em = "$_"
                if ($em -match 'being used by another process' -or $em -match 'access.*denied') {
                    Write-Log "INFO: Skipped locked/in-use file: $($_.FullName)"
                } else {
                    Write-Log "WARN: Copy failed for $($_.FullName): $em"
                }
            }
        }
    }
}

# Defender performance mode helpers
function Test-DefenderAvailable { return [bool](Get-Command -Name Get-MpComputerStatus -ErrorAction SilentlyContinue) }
function Enter-DefenderPerfMode {
    param(
        [string[]]$ExclusionPaths = @('C:\Temp\Bootstrap','C:\Windows\Temp'),
        [switch]$DisableRealtime   = $true
    )
    if (-not (Test-DefenderAvailable)) { return }
    try {
        foreach ($p in $ExclusionPaths) { if ($p -and (Test-Path $p)) { try { Add-MpPreference -ExclusionPath $p -ErrorAction SilentlyContinue } catch {} } }
        foreach ($proc in @('msiexec.exe','powershell.exe','pwsh.exe')) { try { Add-MpPreference -ExclusionProcess $proc -ErrorAction SilentlyContinue } catch {} }
        if ($DisableRealtime) { try { Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction Stop } catch {} }
        Write-Log "Entered Defender perf mode (exclusions set)"
    } catch { Write-Log "WARN: Enter-DefenderPerfMode: $_" }
}
function Exit-DefenderPerfMode {
    param(
        [string[]]$ExclusionPaths = @('C:\Temp\Bootstrap','C:\Windows\Temp'),
        [switch]$ReenableRealtime = $true
    )
    if (-not (Test-DefenderAvailable)) { return }
    try {
        foreach ($p in $ExclusionPaths) { try { Remove-MpPreference -ExclusionPath $p -ErrorAction SilentlyContinue } catch {} }
        foreach ($proc in @('msiexec.exe','powershell.exe','pwsh.exe')) { try { Remove-MpPreference -ExclusionProcess $proc -ErrorAction SilentlyContinue } catch {} }
        if ($ReenableRealtime) { try { Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue } catch {} }
        Write-Log "Exited Defender perf mode (exclusions removed)"
    } catch { Write-Log "WARN: Exit-DefenderPerfMode: $_" }
}

# Provision an APPX/MSIX (SYSTEM-safe): PREFER DISM first, then Add-AppxProvisionedPackage.
function Add-ProvisionedAppxPackageSafe {
    param(
        [Parameter(Mandatory=$true)][string]$PackagePath,
        [string]$LicensePath
    )
    # Try DISM first (preferred under LocalSystem)
    try {
        $args = "/Online /Add-ProvisionedAppxPackage /PackagePath:`"$PackagePath`""
        if ($LicensePath) { $args += " /LicensePath:`"$LicensePath`"" } else { $args += " /SkipLicense" }
        $p = Start-Process -FilePath dism.exe -ArgumentList $args -PassThru -Wait -WindowStyle Hidden
        if ($p.ExitCode -eq 0) { return $true }
        Write-Log "WARN: DISM returned exit code $($p.ExitCode) for ${PackagePath}"
    } catch {
        Write-Log "WARN: DISM failed for ${PackagePath}: $_"
    }

    # Fallback: Add-AppxProvisionedPackage (if available)
    try {
        if (Get-Command Add-AppxProvisionedPackage -ErrorAction SilentlyContinue) {
            if ($LicensePath) {
                Add-AppxProvisionedPackage -Online -PackagePath $PackagePath -LicensePath $LicensePath -ErrorAction Stop | Out-Null
            } else {
                Add-AppxProvisionedPackage -Online -PackagePath $PackagePath -SkipLicense -ErrorAction Stop | Out-Null
            }
            return $true
        } else {
            throw "Add-AppxProvisionedPackage not available on this OS."
        }
    } catch {
        throw "Provisioning failed for ${PackagePath}: $_"
    }
}

# Check if something matching DisplayName pattern is already provisioned
function Test-AppxProvisioned {
    param([Parameter(Mandatory=$true)][string]$DisplayNamePattern)
    try {
        $prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $DisplayNamePattern }
        return [bool]$prov
    } catch { return $false }
}

Write-Log "===================== Init Script Starts) ==========================="
Write-Log "Environment: $Env"
Write-Log "Temp workspace: $TempRoot"
Write-Log "Storage account: $StorageAccount"

# ===================================================================
# Two containers (packages + scripts)
# ===================================================================
$PackagesBase   = "https://$StorageAccount.blob.core.windows.net/packages/"
$ScriptsBase    = "https://$StorageAccount.blob.core.windows.net/scripts/"
function PkgUrl    { param([string]$Name) return ($PackagesBase + $Name) }
function ScriptUrl { param([string]$Name) return ($ScriptsBase  + $Name) }

# ===================================================================
# Managed Identity + Az Storage helpers (wildcards)
# ===================================================================

$global:__AzConnected = $false

function New-StorageContextMI {
    param([Parameter(Mandatory=$true)][string]$AccountName)
    if (-not $global:__AzConnected) { throw "Az context not available for MI." }
    try {
        return (New-AzStorageContext -StorageAccountName $AccountName -UseConnectedAccount)
    } catch {
        throw "Unable to create StorageContext with MI for account '${AccountName}': $_"
    }
}

function Get-BlobLatestByWildcard {
    param(
        [Parameter(Mandatory=$true)][string]$Container,
        [Parameter(Mandatory=$true)][string]$Pattern,
        [Parameter(Mandatory=$true)][string]$AccountName
    )
    $ctx = New-StorageContextMI -AccountName $AccountName
    $blobs = Get-AzStorageBlob -Container $Container -Context $ctx -ErrorAction Stop
    $matches = $blobs | Where-Object { $_.Name -like $Pattern }
    if (-not $matches) { throw "No blob matches '${Pattern}' in container '${Container}'." }
    $best = $matches | Sort-Object { $_.ICloudBlob.Properties.LastModified.UtcDateTime } -Descending | Select-Object -First 1
    return $best.Name
}

function Download-BlobByWildcard {
    param(
        [Parameter(Mandatory=$true)][string]$Container,
        [Parameter(Mandatory=$true)][string]$Pattern,
        [Parameter(Mandatory=$true)][string]$Destination,
        [Parameter(Mandatory=$true)][string]$AccountName
    )
    Ensure-Directory -Path (Split-Path $Destination -Parent)
    $ctx = New-StorageContextMI -AccountName $AccountName
    $name = Get-BlobLatestByWildcard -Container $Container -Pattern $Pattern -AccountName $AccountName
    Write-Log "Downloading blob (MI): ${Container}/${name} -> ${Destination}"
    Get-AzStorageBlobContent -Container $Container -Context $ctx -Blob $name -Destination $Destination -Force -ErrorAction Stop | Out-Null
    if (-not (Test-Path -LiteralPath $Destination)) { throw "Failed to download ${name} to ${Destination}" }
}

function Download-BlobExact {
    param(
        [Parameter(Mandatory=$true)][string]$Container,
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Destination,
        [Parameter(Mandatory=$true)][string]$AccountName
    )
    Ensure-Directory -Path (Split-Path $Destination -Parent)
    $ctx = New-StorageContextMI -AccountName $AccountName
    Write-Log "Downloading blob (MI): ${Container}/${Name} -> ${Destination}"
    Get-AzStorageBlobContent -Container $Container -Context $ctx -Blob $Name -Destination $Destination -Force -ErrorAction Stop | Out-Null
    if (-not (Test-Path -LiteralPath $Destination)) { throw "Failed to download ${Name} to ${Destination}" }
}

# Wrapper that tries MI first, then anonymous HTTP fallback (for resilience)
function Get-PackageByWildcard {
    param(
        [Parameter(Mandatory=$true)][string]$Pattern,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    try {
        Download-BlobByWildcard -Container 'packages' -Pattern $Pattern -Destination $Destination -AccountName $StorageAccount
        return $true
    } catch {
        Write-Log "WARN: MI wildcard download failed for '${Pattern}': $_. Trying anonymous HTTP fallback."
        Download-File -Url (PkgUrl $Pattern) -Destination $Destination
    }
}

function Get-ScriptExact {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    try {
        Download-BlobExact -Container 'scripts' -Name $Name -Destination $Destination -AccountName $StorageAccount
        return $true
    } catch {
        Write-Log "WARN: MI script download failed for '${Name}': $_. Trying anonymous HTTP."
        Download-File -Url (ScriptUrl $Name) -Destination $Destination
    }
}

### v1.29 additions: direct MI blob download without Az modules
# ===================================================================
# NEW in v1.29 - Direct Managed Identity download (no Az modules)
# ===================================================================

function Get-AzStorageTokenMI {
    param(
        [string]$Resource = "https://storage.azure.com/"
    )
    try {
        $headers = @{ Metadata = "true" }
        $url = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$([uri]::EscapeDataString($Resource))"
        $resp = Invoke-RestMethod -Method GET -Uri $url -Headers $headers -ErrorAction Stop
        return $resp.access_token
    } catch {
        throw "Failed to acquire Managed Identity token: $_"
    }
}

function Download-FileMI {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$Destination,
        [int]$MaxRetries = 3
    )
    Ensure-Directory -Path (Split-Path $Destination -Parent)
    Remove-FileSafe -Path $Destination

    $token = Get-AzStorageTokenMI
    $headers = @{ Authorization = "Bearer $token"; "x-ms-version" = "2020-10-02" }

    $attempt = 0
    while ($attempt -lt $MaxRetries) {
        $attempt++
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Destination -Headers $headers -UseBasicParsing -ErrorAction Stop
            if (Test-Path -LiteralPath $Destination) { return $true }
        } catch {
            Write-Log "WARN: MI download attempt $attempt failed for ${Url}: $_"
            Start-Sleep -Seconds (5 * $attempt)
        }
    }
    throw "MI download failed for ${Url} after $MaxRetries attempts."
}

function Get-PackageByWildcardMI {
    param(
        [Parameter(Mandatory=$true)][string]$Pattern,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    # Blob listing requires extra code; here assume exact file name pattern known
    $url = (PkgUrl $Pattern)
    Write-Log "Attempting MI download for package: $Pattern"
    Download-FileMI -Url $url -Destination $Destination
}

function Get-ScriptExactMI {
    param(
        [Parameter(Mandatory=$true)][string]$Name,
        [Parameter(Mandatory=$true)][string]$Destination
    )
    $url = (ScriptUrl $Name)
    Write-Log "Attempting MI download for script: $Name"
    Download-FileMI -Url $url -Destination $Destination
}




# Convert CSV inputs to arrays (safe defaults)
$AppRemoteGroupArray = @()
$AppAdminGroupArray  = @()
if ($AppRemoteGroup) { $AppRemoteGroupArray = ($AppRemoteGroup -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ } }
if ($AppAdminGroup)  { $AppAdminGroupArray  = ($AppAdminGroup  -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ } }

# ===================================================================
# ICMP Firewall Rule (idempotent)
# ===================================================================

Log-Section "Submodule: Enable Ping (ICMPv4)"
try {
    if (-not (Get-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -Protocol ICMPv4 -Enabled True -Action Allow | Out-Null
        Write-Log "Created firewall rule Allow ICMPv4-In"
    } else {
        Write-Log "Firewall rule Allow ICMPv4-In already exists"
    }
} catch { Write-Log "WARN: ICMP rule step: $_" }

# ===================================================================
# RAW Disk Initialization
# ===================================================================

Log-Section "Submodule: Initialize RAW Disks"
try {
    $raw = Get-Disk | Where-Object { $_.PartitionStyle -eq 'RAW' -and -not $_.IsBoot -and -not $_.IsSystem }
    if ($raw) {
        foreach ($d in $raw) {
            Write-Log "Initializing RAW disk Number=$($d.Number)"
            $disk = Initialize-Disk -Number $d.Number -PartitionStyle GPT -PassThru
            $part = New-Partition -DiskNumber $disk.Number -AssignDriveLetter -UseMaximumSize
            $label = "Data$($disk.Number)"
            Format-Volume -Partition $part -FileSystem NTFS -NewFileSystemLabel $label -Confirm:$false | Out-Null
            Write-Log "Disk $($disk.Number) formatted as $label"
        }
    } else {
        Write-Log "No RAW data disks found"
    }
} catch { Write-Log "WARN: Disk initialization step: $_" }

# ===================================================================
# HEAVY WORK: Software installs (Defender perf mode ON)
# ===================================================================

Enter-DefenderPerfMode -ExclusionPaths @($TempRoot,'C:\Windows\Temp') -DisableRealtime
$AzLoggedIn = $false

# newer versions of this script fetch az-modules.zip via MI

# --------------------------------------------------------------
# Submodule: Az Modules (PS 5.1 via MI-first, fallback HTTPS)
# --------------------------------------------------------------
Log-Section "Submodule: Az Modules (PS 5.1)"
try {
    $step = 'Az Modules (PS 5.1)'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"

    $AzZipName    = 'az-modules.zip'
    $AzZipPath    = Join-Path $DlDir  $AzZipName
    $AzExtractDir = Join-Path $WorkDir 'azmods_extracted'
    $Ps51Modules  = Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'

    # --- Try Managed Identity download first ---
    Write-Log "${step}: download start (MI) -> ${AzZipName}"
    $dlStart = Get-Date
    $downloaded = $false
    try {
        $url = (PkgUrl $AzZipName)
        Download-FileMI -Url $url -Destination $AzZipPath
        $downloaded = $true
        Write-Log "${step}: MI download successful"
    } catch {
        Write-Log "WARN: ${step} MI download failed: $_. Falling back to HTTPS"
    }

    # --- Fallback: HTTPS (anonymous/public or SAS) ---
    if (-not $downloaded) {
        Write-Log "${step}: download start (HTTPS) -> ${AzZipName}"
        try {
            Download-File -Url (PkgUrl $AzZipName) -Destination $AzZipPath
            $downloaded = $true
            Write-Log "${step}: HTTPS download successful"
        } catch {
            throw "Both MI and HTTPS download attempts failed for ${AzZipName}"
        }
    }

    $dlEnd = Get-Date
    Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting extraction"

    if (Test-Path $AzExtractDir) { Remove-Item $AzExtractDir -Recurse -Force -ErrorAction SilentlyContinue }
    Expand-Archive -Path $AzZipPath -DestinationPath $AzExtractDir -Force

    Ensure-Directory -Path $Ps51Modules
    $moduleFolders = Get-ChildItem $AzExtractDir -Directory
    if (-not $moduleFolders) { throw "No module folders found in $AzExtractDir" }

    foreach ($mod in $moduleFolders) {
        $target = Join-Path $Ps51Modules $mod.Name
        Copy-FolderFast -Source $mod.FullName -Destination $target
    }

    try {
        Import-Module Az.Accounts -ErrorAction Stop
        Write-Log "${step}: Az.Accounts imported"
    } catch {
        Write-Log "WARN: Import Az.Accounts after ${step}: $_"
    }

    Remove-FileSafe -Path $AzZipPath

    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: completed at $t1 (total $(Format-Duration $span))"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch {
    $em = "$_"
    if ($em -match 'being used by another process' -or $em -match 'access.*denied') {
        Write-Log "INFO: ${step} appears installed/in use; continuing."
    } else {
        Write-Log "ERROR: ${step} failed: $em"
        Exit 1
    }
}


# try {

#     # --------------------------------------------------------------
#     # Submodule: Az Modules (PS 5.1 via direct HTTPS, no MI)
#     # --------------------------------------------------------------
#     Log-Section "Submodule: Az Modules (PS 5.1 via HTTPS)"
#     try {
#         $step = 'Az Modules (PS 5.1)'
#         $t0 = Get-Date
#         Write-Log "${step}: start at $t0"
#         $AzZipName    = 'az-modules.zip'
#         $AzZipPath    = Join-Path $DlDir  $AzZipName
#         $AzExtractDir = Join-Path $WorkDir 'azmods_extracted'
#         $Ps51Modules  = Join-Path $env:ProgramFiles 'WindowsPowerShell\Modules'

#         Write-Log "${step}: download start (HTTPS) -> ${AzZipName}"
#         $dlStart = Get-Date
#         Download-File -Url (PkgUrl $AzZipName) -Destination $AzZipPath
#         $dlEnd = Get-Date
#         Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting extraction"

#         if (Test-Path $AzExtractDir) { Remove-Item $AzExtractDir -Recurse -Force -ErrorAction SilentlyContinue }
#         Expand-Archive -Path $AzZipPath -DestinationPath $AzExtractDir -Force

#         Ensure-Directory -Path $Ps51Modules
#         $moduleFolders = Get-ChildItem $AzExtractDir -Directory
#         if (-not $moduleFolders) { throw "No module folders found in $AzExtractDir" }

#         foreach ($mod in $moduleFolders) {
#             $target = Join-Path $Ps51Modules $mod.Name
#             Copy-FolderFast -Source $mod.FullName -Destination $target
#         }

#         try {
#             Import-Module Az.Accounts -ErrorAction Stop
#             Write-Log "${step}: Az.Accounts imported"
#         } catch {
#             Write-Log "WARN: Import Az.Accounts after ${step}: $_"
#         }

#         Remove-FileSafe -Path $AzZipPath

#         $t1 = Get-Date
#         $span = New-TimeSpan -Start $t0 -End $t1
#         Write-Log "${step}: completed at $t1 (total $(Format-Duration $span))"
#         Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
#     } catch {
#         $em = "$_"
#         if ($em -match 'being used by another process' -or $em -match 'access.*denied') {
#             Write-Log "INFO: ${step} appears installed/in use; continuing."
#         } else {
#             Write-Log "ERROR: ${step} failed: $em"
#             Exit 1
#         }
#     }

    # --------------------------------------------------------------
    # Submodule: Azure Managed Identity Login (now that Az is present)
    # --------------------------------------------------------------
    Log-Section "Submodule: Azure Managed Identity Login"
    try {
        $step = 'Azure Managed Identity Login'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        if (-not (Get-AzContext -ErrorAction SilentlyContinue)) {
            Connect-AzAccount -Identity -ErrorAction Stop | Out-Null
            $global:__AzConnected = $true
            $AzLoggedIn = $true
            Write-Log "${step}: Az login via Managed Identity successful"
        } else {
            $global:__AzConnected = $true
            $AzLoggedIn = $true
            Write-Log "${step}: Az context already present"
        }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: completed at $t1 (total $(Format-Duration $span))"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "WARN: ${step} failed: $_" }

    # --------------------------------------------------------------
    # Submodule: PowerShell 7 (wildcard via MI)
    # --------------------------------------------------------------
    Log-Section "Submodule: PowerShell 7"
    try {
        $step = 'PowerShell 7'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $pwshPath = 'C:\Program Files\PowerShell\7\pwsh.exe'
        $psMsi    = Join-Path $DlDir 'PowerShell-win-x64-latest.msi'
        if (-not (Test-Path $pwshPath)) {
            Write-Log "${step}: download start -> PowerShell-*-win-x64.msi"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'PowerShell-*-win-x64.msi' -Destination $psMsi
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            $instStart = Get-Date
            Start-Process msiexec.exe -ArgumentList "/i `"$psMsi`" /qn /norestart" -Wait -WindowStyle Hidden
            $instEnd = Get-Date
            Write-Log "${step}: installation finished at $instEnd (install $(Format-Duration (New-TimeSpan -Start $instStart -End $instEnd)))"
        } else {
            Write-Log "${step}: already present, skipping"
        }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: PowerShell 7 step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: Az Modules (PS 7 copy)
    # --------------------------------------------------------------
    Log-Section "Submodule: Az Modules (PS 7 copy)"
    try {
        $step = 'Az Modules (PS 7 copy)'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $Ps7ModulesPath = Join-Path $env:ProgramFiles 'PowerShell\7\Modules'
        if (Test-Path $Ps7ModulesPath) {
            Ensure-Directory -Path $Ps7ModulesPath
            $AzExtractDir = Join-Path $WorkDir 'azmods_extracted'
            $moduleFolders = Get-ChildItem $AzExtractDir -Directory -ErrorAction SilentlyContinue
            if ($moduleFolders) {
                foreach ($mod in $moduleFolders) {
                    $target = Join-Path $Ps7ModulesPath $mod.Name
                    Copy-FolderFast -Source $mod.FullName -Destination $target
                }
            } else {
                Write-Log "WARN: No module folders found for PS 7 copy"
            }
        } else {
            Write-Log "WARN: PS 7 modules path not found; skipping copy"
        }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: completed at $t1 (total $(Format-Duration $span))"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "WARN: Copy modules to PS 7 failed: $_" }

    # --------------------------------------------------------------
    # Submodule: Windows Terminal (Server-safe provisioning; DISM first)
    # --------------------------------------------------------------
    Log-Section "Submodule: Windows Terminal"
    try {
        $step = 'Windows Terminal'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $wtWork = Join-Path $WorkDir 'WindowsTerminal'
        $wtZip  = Join-Path $DlDir   'WindowsTerminal_PreinstallKit.zip'
        if (Test-Path $wtWork) { Remove-Item $wtWork -Recurse -Force -ErrorAction SilentlyContinue }

        Write-Log "${step}: download start -> WindowsTerminal PreinstallKit zip (wildcard)"
        $dlStart = Get-Date
        Get-PackageByWildcard -Pattern 'Microsoft.WindowsTerminal_*_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip' -Destination $wtZip
        $dlEnd = Get-Date
        Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), expanding and validating"
        Expand-Archive -Path $wtZip -DestinationPath $wtWork -Force

        # Locate dependencies and bundle
        $xaml    = Get-ChildItem $wtWork -Filter 'Microsoft.UI.Xaml.*x64*.appx' -Recurse | Select-Object -First 1
        $vclibs  = Get-ChildItem $wtWork -Filter 'Microsoft.VCLibs.*UWPDesktop*.*x64*.appx' -Recurse | Select-Object -First 1
        $bundle  = Get-ChildItem $wtWork -Filter '*.msixbundle' -Recurse | Select-Object -First 1
        $license = Get-ChildItem $wtWork -Filter '*_License*.xml' -Recurse | Select-Object -First 1

        if ($xaml) {
            if (-not (Test-AppxProvisioned -DisplayNamePattern 'Microsoft.UI.Xaml*')) {
                Write-Log "${step}: provisioning Microsoft.UI.Xaml (DISM preferred)"
                Add-ProvisionedAppxPackageSafe -PackagePath $xaml.FullName | Out-Null
            } else {
                Write-Log "${step}: Microsoft.UI.Xaml already provisioned"
            }
        } else {
            Write-Log "WARN: ${step} could not find Microsoft.UI.Xaml (x64) appx in kit; it may already be present on the OS."
        }

        if ($vclibs) {
            if (-not (Test-AppxProvisioned -DisplayNamePattern 'Microsoft.VCLibs*UWPDesktop*')) {
                Write-Log "${step}: provisioning Microsoft.VCLibs UWPDesktop (x64) (DISM preferred)"
                Add-ProvisionedAppxPackageSafe -PackagePath $vclibs.FullName | Out-Null
            } else {
                Write-Log "${step}: Microsoft.VCLibs UWPDesktop (x64) already provisioned"
            }
        } else {
            Write-Log "WARN: ${step} VCLibs UWPDesktop (x64) not found in kit; proceeding."
        }

        if ($bundle) {
            if (-not (Test-AppxProvisioned -DisplayNamePattern 'Microsoft.WindowsTerminal*')) {
                if (-not $license) { throw "Windows Terminal license xml not found; cannot provision bundle." }
                Write-Log "${step}: provisioning Windows Terminal bundle for all users (DISM preferred)"
                Add-ProvisionedAppxPackageSafe -PackagePath $bundle.FullName -LicensePath $license.FullName | Out-Null
                Write-Log "${step}: Windows Terminal provisioned"
            } else {
                Write-Log "${step}: already provisioned; skipping"
            }
        } else {
            throw "Windows Terminal bundle not found in preinstall kit."
        }

        try { Set-ItemProperty -Path "HKCU:\Console" -Name "DefaultTerminalApp" -Value "WindowsTerminal" } catch {}

        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: completed at $t1 (total $(Format-Duration $span))"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch {
        Write-Log "WARN: Windows Terminal step aborted: $_"
    }

    # --------------------------------------------------------------
    # Submodule: Azure CLI (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: Azure CLI"
    try {
        $step = 'Azure CLI'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $azCliExe = (Get-Command az -ErrorAction SilentlyContinue)
        $azMsi    = Join-Path $DlDir 'azure-cli-latest-x64.msi'
        if (-not $azCliExe) {
            Write-Log "${step}: download start -> azure-cli-*.msi"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'azure-cli-*.msi' -Destination $azMsi
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            $instStart = Get-Date
            Start-Process msiexec.exe -ArgumentList "/i `"$azMsi`" /qn /norestart" -Wait -WindowStyle Hidden
            $instEnd = Get-Date
            Write-Log "${step}: installation finished at $instEnd (install $(Format-Duration (New-TimeSpan -Start $instStart -End $instEnd)))"
        } else {
            Write-Log "${step}: already present, skipping"
        }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: Azure CLI step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: AWS CLI (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: AWS CLI"
    try {
        $step = 'AWS CLI'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $awsExe = (Get-Command aws -ErrorAction SilentlyContinue)
        $awsMsi = Join-Path $DlDir 'AWSCLIV2-latest.msi'
        if (-not $awsExe) {
            Write-Log "${step}: download start -> AWSCLIV2*.msi"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'AWSCLIV2*.msi' -Destination $awsMsi
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            $instStart = Get-Date
            Start-Process msiexec.exe -ArgumentList "/i `"$awsMsi`" /qn /norestart" -Wait -WindowStyle Hidden
            $instEnd = Get-Date
            Write-Log "${step}: installation finished at $instEnd (install $(Format-Duration (New-TimeSpan -Start $instStart -End $instEnd)))"
        } else { Write-Log "${step}: already present, skipping" }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: AWS CLI step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: 7-Zip (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: 7-Zip"
    try {
        $step = '7-Zip'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $sevenZip = 'C:\Program Files\7-Zip\7z.exe'
        $zipMsi   = Join-Path $DlDir '7zip-latest-x64.msi'
        if (-not (Test-Path $sevenZip)) {
            Write-Log "${step}: download start -> 7z*-x64.msi"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern '7z*-x64.msi' -Destination $zipMsi
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            $instStart = Get-Date
            Start-Process msiexec.exe -ArgumentList "/i `"$zipMsi`" /qn /norestart" -Wait -WindowStyle Hidden
            $instEnd = Get-Date
            Write-Log "${step}: installation finished at $instEnd (install $(Format-Duration (New-TimeSpan -Start $instStart -End $instEnd)))"
        } else { Write-Log "${step}: already present, skipping" }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: 7-Zip step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: Sysinternals Suite (wildcard zip)
    # --------------------------------------------------------------
    Log-Section "Submodule: Sysinternals Suite"
    try {
        $step = 'Sysinternals Suite'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $sysZip = Join-Path $DlDir 'SysinternalsSuite.zip'
        Write-Log "${step}: download start -> SysinternalsSuite*.zip"
        $dlStart = Get-Date
        Get-PackageByWildcard -Pattern 'SysinternalsSuite*.zip' -Destination $sysZip
        $dlEnd = Get-Date
        Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting extract to System32"
        Expand-Archive -Path $sysZip -DestinationPath 'C:\Windows\System32' -Force
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: Sysinternals step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: VS Code (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: VS Code"
    try {
        $step = 'VS Code'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $codePath = 'C:\Program Files\Microsoft VS Code\Code.exe'
        $codeExe  = Join-Path $DlDir 'VSCodeSetup-x64-latest.exe'
        if (-not (Test-Path $codePath)) {
            Write-Log "${step}: download start -> VSCodeSetup-x64-*.exe"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'VSCodeSetup-x64-*.exe' -Destination $codeExe
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            Start-Process -FilePath $codeExe -ArgumentList '/verysilent /suppressmsgboxes /mergetasks=!runcode' -Wait -WindowStyle Hidden
        } else { Write-Log "${step}: already present, skipping" }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: VS Code step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: Azure Storage Explorer (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: Azure Storage Explorer"
    try {
        $step = 'Azure Storage Explorer'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $sePath = 'C:\Program Files\Microsoft Azure Storage Explorer\StorageExplorer.exe'
        $seExe  = Join-Path $DlDir 'StorageExplorer-windows-x64-latest.exe'
        if (-not (Test-Path $sePath)) {
            Write-Log "${step}: download start -> StorageExplorer-windows-x64*.exe"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'StorageExplorer-windows-x64*.exe' -Destination $seExe
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            Start-Process -FilePath $seExe -ArgumentList '/ALLUSERS /VERYSILENT /SP- /SUPPRESSMSGBOXES /NORESTART' -Wait -WindowStyle Hidden
        } else { Write-Log "${step}: already present, skipping" }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: Storage Explorer step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: Azure Data Studio (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: Azure Data Studio"
    try {
        $step = 'Azure Data Studio'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $adsExePath  = 'C:\Program Files\Azure Data Studio\azuredatastudio.exe'
        $adsSetupExe = Join-Path $DlDir 'azuredatastudio-windows-setup-latest.exe'
        if (-not (Test-Path $adsExePath)) {
            Write-Log "${step}: download start -> azuredatastudio-windows-setup-*.exe"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'azuredatastudio-windows-setup-*.exe' -Destination $adsSetupExe
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            Start-Process -FilePath $adsSetupExe -ArgumentList '/sp- /verysilent /suppressmsgboxes /norestart /MERGETASKS=!runcode' -Wait -WindowStyle Hidden
        } else { Write-Log "${step}: already present, skipping" }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: Azure Data Studio step failed: $_"; Exit 1 }

    # --------------------------------------------------------------
    # Submodule: Postman (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: Postman"
    function Ensure-PostmanShortcut {
        try {
            $shell = New-Object -ComObject WScript.Shell
            $sc = $shell.CreateShortcut('C:\Users\Public\Desktop\Postman.lnk')
            $sc.TargetPath = 'C:\Program Files\Postman\Postman.exe'
            $sc.Save()
            Write-Log "Postman Public desktop shortcut ensured"
        } catch { Write-Log "WARN: Could not create Postman shortcut: $_" }
    }
    function Cleanup-PostmanDuplicateShortcuts {
        try {
            $publicShortcut = 'C:\Users\Public\Desktop\Postman.lnk'
            $currentUserDesktop = [Environment]::GetFolderPath('Desktop')
            $userShortcut = Join-Path $currentUserDesktop 'Postman.lnk'
            $publicExists = Test-Path $publicShortcut
            $userExists   = Test-Path $userShortcut
            if ($publicExists -and $userExists) {
                Remove-Item $userShortcut -Force -ErrorAction SilentlyContinue
                Write-Log "Removed per-user Postman shortcut at ${userShortcut} (Public exists)"
            }
            if ($publicExists) {
                Get-ChildItem 'C:\Users' -Directory -ErrorAction SilentlyContinue |
                  Where-Object { $_.Name -notin @('Public','Default','Default User','All Users') } |
                  ForEach-Object {
                      $p = Join-Path $_.FullName 'Desktop\Postman.lnk'
                      if (Test-Path $p) {
                          Remove-Item $p -Force -ErrorAction SilentlyContinue
                          Write-Log "Removed Postman shortcut from profile: $($_.Name)"
                      }
                  }
            }
        } catch { Write-Log "WARN: Postman duplicate shortcut cleanup: $_" }
    }
    try {
        $step = 'Postman'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $pmProgramFiles = 'C:\Program Files\Postman\Postman.exe'
        if (Test-Path $pmProgramFiles) {
            Write-Log "${step}: already present, ensuring shortcuts"
            Ensure-PostmanShortcut
            Cleanup-PostmanDuplicateShortcuts
        } else {
            Get-Process -Name Postman, PostmanAgent -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
            $pmExe   = Join-Path $DlDir 'Postman-win64-Setup-latest.exe'
            $pmLocal = Join-Path $env:LOCALAPPDATA 'Postman'

            Write-Log "${step}: download start -> Postman-win64-Setup*.exe"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'Postman-win64-Setup*.exe' -Destination $pmExe
            $dlEnd = Get-Date
            Write-Log "${step}: download end at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd)))"

            $instStart = Get-Date
            $p = Start-Process -FilePath $pmExe -ArgumentList '--silent' -PassThru -WindowStyle Hidden
            $deadline = (Get-Date).AddMinutes(5)
            while ((Get-Date) -lt $deadline) {
                if ($p.HasExited) { break }
                if (Test-Path $pmLocal) { break }
                Start-Sleep -Seconds 5
            }
            if (-not $p.HasExited) { try { Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue } catch {} }
            if (-not (Test-Path $pmLocal) -and -not (Test-Path $pmProgramFiles)) {
                Write-Log "WARN: ${step} first silent attempt did not complete; trying fallback switch /S"
                $p2 = Start-Process -FilePath $pmExe -ArgumentList '/S' -PassThru -WindowStyle Hidden
                $deadline2 = (Get-Date).AddMinutes(3)
                while ((Get-Date) -lt $deadline2) {
                    if ($p2.HasExited) { break }
                    if (Test-Path $pmLocal) { break }
                    Start-Sleep -Seconds 5
                }
                if (-not $p2.HasExited) { try { Stop-Process -Id $p2.Id -Force -ErrorAction SilentlyContinue } catch {} }
            }
            $instEnd = Get-Date
            Write-Log "${step}: installer phase finished at $instEnd (install phase $(Format-Duration (New-TimeSpan -Start $instStart -End $instEnd)))"

            if (Test-Path $pmLocal) {
                Ensure-Directory -Path 'C:\Program Files\Postman'
                Copy-FolderFast -Source $pmLocal -Destination 'C:\Program Files\Postman'
            }
            if (Test-Path $pmProgramFiles) {
                Ensure-PostmanShortcut
                Cleanup-PostmanDuplicateShortcuts
                Write-Log "${step}: installation verified"
            } else {
                Write-Log "WARN: ${step} installation could not be verified; leaving as unattended and continuing"
            }
        }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: Postman step failed: $_" }

    # --------------------------------------------------------------
    # Submodule: MobaXterm (wildcard)
    # --------------------------------------------------------------
    Log-Section "Submodule: MobaXterm"
    try {
        $step = 'MobaXterm'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $mobaExe  = 'C:\Program Files (x86)\Mobatek\MobaXterm\MobaXterm.exe'
        $mobaZip  = Join-Path $DlDir 'MobaXterm_Installer_latest.zip'
        $mobaWork = Join-Path $WorkDir 'MobaXterm_Installer_latest'
        if (-not (Test-Path $mobaExe)) {
            Write-Log "${step}: download start -> MobaXterm_Installer_v*.zip"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'MobaXterm_Installer_v*.zip' -Destination $mobaZip
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            if (Test-Path $mobaWork) { Remove-Item $mobaWork -Recurse -Force -ErrorAction SilentlyContinue }
            Expand-Archive -Path $mobaZip -DestinationPath $mobaWork -Force
            $msi = Get-ChildItem -Path $mobaWork -Filter '*.msi' -Recurse | Select-Object -First 1
            if ($msi) {
                Start-Process msiexec.exe -ArgumentList "/i `"$($msi.FullName)`" /qn /norestart" -Wait -WindowStyle Hidden
            } else { Write-Log "WARN: ${step} MSI not found in archive" }
        } else { Write-Log "${step}: already present, skipping" }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: MobaXterm step failed: $_"; Exit 1 }


# --------------------------------------------------------------
# Submodule: AzCopy (wildcard zip)
# --------------------------------------------------------------
    Log-Section "Submodule: AzCopy"
    try {
        $step = 'AzCopy'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $azcopyExe = 'C:\Program Files\AzCopy\azcopy.exe'
        $azcopyZip = Join-Path $DlDir 'azcopy_windows_amd64_10.30.1.zip'
        $azcopyDest = 'C:\Program Files\AzCopy'
        if (-not (Test-Path $azcopyExe)) {
            Write-Log "${step}: download start -> azcopy_windows_amd64_10.30.1.zip"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'azcopy_windows_amd64_10.30.1.zip' -Destination $azcopyZip
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), extracting"
            if (Test-Path $azcopyDest) { Remove-Item $azcopyDest -Recurse -Force -ErrorAction SilentlyContinue }
            Expand-Archive -Path $azcopyZip -DestinationPath $azcopyDest -Force
            # Move azcopy.exe up if needed (the zip usually contains a subfolder)
            $azcopyExeFound = Get-ChildItem -Path $azcopyDest -Recurse -Filter 'azcopy.exe' | Select-Object -First 1
            if ($azcopyExeFound -and $azcopyExeFound.FullName -ne $azcopyExe) {
                Move-Item -Path $azcopyExeFound.FullName -Destination $azcopyExe -Force
            }
            Write-Log "${step}: extraction complete"
        } else {
            Write-Log "${step}: already present, skipping"
        }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span)"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "ERROR: AzCopy step failed: $_"; Exit 1 }
finally {
    Exit-DefenderPerfMode -ExclusionPaths @($TempRoot,'C:\Windows\Temp') -ReenableRealtime
}
# ===================================================================
# PATH updates (idempotent)
# ===================================================================
Log-Section "Submodule: PATH Updates"
try {
    $adds = @(
        'C:\Program Files\Amazon\AWSCLIV2\',
        'C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin',
        'C:\Program Files\PowerShell\7\',
        'C:\Program Files\AzCopy\' # Add AzCopy to PATH
    )
    $cur = [System.Environment]::GetEnvironmentVariable('Path','Machine')
    foreach ($p in $adds) { if ($cur -notlike "*$p*") { $cur = "$cur;$p" } }
    [System.Environment]::SetEnvironmentVariable('Path', $cur, 'Machine')
    $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')
    Write-Log "PATH updated"
} catch { Write-Log "WARN: PATH update: $_" }

# ===================================================================
# Optional Az context verification
# ===================================================================
Log-Section "Submodule: Az Context Verification"
if ($AzLoggedIn) {
    try {
        $null = Get-AzContext -ErrorAction Stop
        Write-Log "Managed Identity context exists"
    } catch { Write-Log "WARN: Could not confirm Az context: $_" }
} else {
    Write-Log "WARN: Skipping Az context verification (not logged in)"
}

# ===================================================================
# OpenSSH server + authorized_keys from scripts container
# ===================================================================
Log-Section "Submodule: OpenSSH Server"
try {
    $step = 'OpenSSH Server'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"

    $cap = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
    if ($cap.State -ne 'Installed') {
        Add-WindowsCapability -Online -Name 'OpenSSH.Server~~~~0.0.1.0' | Out-Null
        Write-Log "${step}: capability installed"
    } else { Write-Log "${step}: capability already installed" }

    Set-Service -Name sshd -StartupType Automatic
    if ((Get-Service sshd -ErrorAction SilentlyContinue).Status -ne 'Running') { Start-Service sshd }

    if (-not (Get-NetFirewallRule -DisplayName 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH-Server-In-TCP' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22 | Out-Null
        Write-Log "${step}: firewall rule created"
    } else { Write-Log "${step}: firewall rule exists" }

    $authorizedKeysPath = 'C:\ProgramData\ssh\administrators_authorized_keys'
    Ensure-Directory -Path (Split-Path $authorizedKeysPath -Parent)

    $pubKeyTemp = Join-Path $DlDir 'azureadmin-pubkey.tmp'
    Write-Log "${step}: download start -> scripts/azureadmin-pubkey"
    $dlStart = Get-Date
    $downloaded = $false
    try {
        Get-ScriptExact -Name 'azureadmin-pubkey' -Destination $pubKeyTemp
        $downloaded = $true
    } catch { Write-Log "WARN: ${step} could not download azureadmin-pubkey: $_" }
    $dlEnd = Get-Date
    Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd)))"

    if ($downloaded -and (Test-Path $pubKeyTemp)) {
        $pubKey = Get-Content -Path $pubKeyTemp -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($pubKey) {
            Set-Content -Path $authorizedKeysPath -Value $pubKey -Encoding ascii -Force
            icacls $authorizedKeysPath /inheritance:r | Out-Null
            icacls $authorizedKeysPath /grant:r "Administrators:F" /grant:r "SYSTEM:F" | Out-Null
            icacls $authorizedKeysPath /remove "NT AUTHORITY\Authenticated Users" | Out-Null
            Write-Log "${step}: authorized_keys updated"
        } else { Write-Log "WARN: ${step} downloaded key empty" }
    } else { Write-Log "WARN: ${step} could not retrieve key; authorized_keys not updated" }

    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: total $(Format-Duration $span)"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch { Write-Log "WARN: OpenSSH step: $_" }

# ===================================================================
# BGInfo (from scripts) + Startup shortcut
# ===================================================================
Log-Section "Submodule: BGInfo"
try {
    $step = 'BGInfo'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"
    $configPath    = 'C:\Windows\default.bgi'
    $bginfoExe     = 'C:\Windows\System32\Bginfo.exe'
    $startupFolder = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup'
    $shortcutPath  = Join-Path $startupFolder 'BGInfo.lnk'
    Write-Log "${step}: download start -> scripts/default.bgi"
    $dlStart = Get-Date
    Get-ScriptExact -Name 'default.bgi' -Destination $configPath
    $dlEnd = Get-Date
    Write-Log "${step}: download done at $dlEnd, creating startup shortcut"
    $wshShell  = New-Object -ComObject WScript.Shell
    $shortcut  = $wshShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $bginfoExe
    $shortcut.Arguments  = "`"$configPath`" /timer:0 /silent /nolicprompt"
    $shortcut.Save()
    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: total $(Format-Duration $span)"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch { Write-Log "ERROR: BGInfo setup failed: $_"; Exit 1 }

Log-Section "Submodule: Terraform"
try {
    $step = 'Terraform'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"

    $terraformExe = 'C:\Windows\System32\terraform.exe'
    $terraformZip = Join-Path $DlDir 'terraform.zip'
    $terraformExtract = Join-Path $WorkDir 'terraform_extracted'

    if (-not (Test-Path $terraformExe)) {
        Write-Log "${step}: download start -> terraform*.zip"
        $dlStart = Get-Date
        Get-PackageByWildcard -Pattern 'terraform*.zip' -Destination $terraformZip
        $dlEnd = Get-Date
        Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), extracting"

        if (Test-Path $terraformExtract) {
            Remove-Item $terraformExtract -Recurse -Force -ErrorAction SilentlyContinue
        }
        Expand-Archive -Path $terraformZip -DestinationPath $terraformExtract -Force

        $foundTerraform = Get-ChildItem -Path $terraformExtract -Recurse -Filter 'terraform.exe' | Select-Object -First 1
        if (-not $foundTerraform) { throw "terraform.exe not found in package" }

        Copy-Item -LiteralPath $foundTerraform.FullName -Destination $terraformExe -Force
        Write-Log "${step}: terraform.exe copied to System32"
    } else {
        Write-Log "${step}: already present, skipping"
    }

    # Terraform PATH entry (System32 already in PATH, but add for safety)
    try {
        $cur = [System.Environment]::GetEnvironmentVariable('Path','Machine')
        if ($cur -notlike '*C:\Windows\System32*') {
            [System.Environment]::SetEnvironmentVariable('Path', "$cur;C:\Windows\System32", 'Machine')
        }
    } catch {
        Write-Log "WARN: ${step} PATH update: $_"
    }

    # Verify
    try {
        $tfv = terraform.exe -version
        Write-Log "${step}: terraform version: $tfv"
    } catch {
        Write-Log "WARN: ${step} terraform.exe verification failed: $_"
    }

    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: total $(Format-Duration $span)"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch {
    Write-Log "ERROR: Terraform step failed: $_"
}

# ===================================================================
# scheduled.ps1 (from scripts) + Scheduled Task
# ===================================================================
Log-Section "Submodule: Scheduled Task (scheduled.ps1)"
try {
    $step = 'Scheduled Task (scheduled.ps1)'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"
    $sched = Join-Path $WorkDir 'scheduled.ps1'
    Write-Log "${step}: download start -> scripts/scheduled.ps1"
    $dlStart = Get-Date
    Get-ScriptExact -Name 'scheduled.ps1' -Destination $sched
    $dlEnd = Get-Date
    Write-Log "${step}: download done at $dlEnd, registering task"
    Unblock-File -Path $sched -ErrorAction SilentlyContinue
    $Action  = New-ScheduledTaskAction -Execute 'powershell.exe' -Argument "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `"$sched`""
    $Trigger = New-ScheduledTaskTrigger -AtLogOn
    try {
        $Principal = New-ScheduledTaskPrincipal -UserId 'azureadmin' -LogonType Interactive -RunLevel Highest
    } catch {
        Write-Log "WARN: azureadmin principal not found, falling back to INTERACTIVE"
        $Principal = New-ScheduledTaskPrincipal -UserId 'INTERACTIVE' -LogonType Interactive
    }
    Register-ScheduledTask -TaskName 'RunAppxInstall' -Action $Action -Trigger $Trigger -Principal $Principal -Force | Out-Null
    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: total $(Format-Duration $span)"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch { Write-Log "ERROR: Scheduled task setup failed: $_"; Exit 1 }

# ===================================================================
# Azure Arc Surfacing Cleanup
# ===================================================================
Log-Section "Submodule: Azure Arc Surfacing Cleanup"
try {
    $step = 'Azure Arc Surfacing Cleanup'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\ServerManager') {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotPopulateAzureArcTiles' -Value 1 -ErrorAction SilentlyContinue
    }
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System') {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'DisableAzureArcSetup' -Value 1 -ErrorAction SilentlyContinue
    }
    $arcShortcut = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Azure Arc Setup.lnk'
    if (Test-Path $arcShortcut) { Remove-Item $arcShortcut -Force -ErrorAction SilentlyContinue }
    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: completed (total $(Format-Duration $span))"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch { Write-Log "WARN: Azure Arc cleanup: $_" }

# ===================================================================
# WinRM Enablement
# ===================================================================
Log-Section "Submodule: WinRM Enablement"
try {
    $step = 'WinRM Enablement'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"
    winrm quickconfig -q
    winrm set winrm/config/service '@{AllowUnencrypted=true}'
    winrm set winrm/config/service/auth '@{Basic=true}'
    try { netsh advfirewall firewall set rule group='Windows Remote Management' new enable=yes | Out-Null } catch {}
    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: completed (total $(Format-Duration $span))"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch { Write-Log "WARN: WinRM step: $_" }

# ===================================================================
# Local group memberships
# ===================================================================
Log-Section "Submodule: Local Group Memberships"
try {
    $step = 'Local Group Memberships'
    $t0 = Get-Date
    Write-Log "${step}: start at $t0"
    foreach ($g in $AppAdminGroupArray)  { if ($g) { Add-LocalGroupMember -Group 'Administrators'        -Member $g -ErrorAction SilentlyContinue } }
    foreach ($g in $AppRemoteGroupArray) { if ($g) { Add-LocalGroupMember -Group 'Remote Desktop Users' -Member $g -ErrorAction SilentlyContinue } }
    if ($AppAdminGroupArray -or $AppRemoteGroupArray) { Write-Log "Local group memberships updated" } else { Write-Log "No group inputs provided; skipping updates" }
    $t1 = Get-Date
    $span = New-TimeSpan -Start $t0 -End $t1
    Write-Log "${step}: completed (total $(Format-Duration $span))"
    Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
} catch { Write-Log "WARN: Local group membership step: $_" }

# ===================================================================
# Optional: SHIR (packages container)
# ===================================================================
if ($EnableSHIR) {
    Log-Section "Submodule: Self-hosted Integration Runtime (optional)"
    Enter-DefenderPerfMode -ExclusionPaths @($TempRoot,'C:\Windows\Temp') -DisableRealtime
    try {
        $step = 'Self-hosted Integration Runtime'
        $t0 = Get-Date
        Write-Log "${step}: start at $t0"
        $shirPaths = @(
            'C:\Program Files\Microsoft Integration Runtime\5.0\Shared\IntegrationRuntime.ConfigurationManager.exe',
            'C:\Program Files\Microsoft Integration Runtime\4.0\Shared\IntegrationRuntime.ConfigurationManager.exe',
            'C:\Program Files\Microsoft Integration Runtime\3.0\Shared\IntegrationRuntime.ConfigurationManager.exe'
        )
        $shirInstalled = $false
        foreach ($p in $shirPaths) { if (Test-Path $p) { $shirInstalled = $true; break } }
        if (-not $shirInstalled) {
            $msi = Join-Path $DlDir 'IntegrationRuntime-latest.msi'
            Write-Log "${step}: download start -> IntegrationRuntime_*.msi"
            $dlStart = Get-Date
            Get-PackageByWildcard -Pattern 'IntegrationRuntime_*.msi' -Destination $msi
            $dlEnd = Get-Date
            Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
            Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -WindowStyle Hidden
        } else {
            Write-Log "${step}: already installed, skipping"
        }
        $t1 = Get-Date
        $span = New-TimeSpan -Start $t0 -End $t1
        Write-Log "${step}: total $(Format-Duration $span))"
        Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
    } catch { Write-Log "WARN: SHIR step: $_" }
    finally {
        Exit-DefenderPerfMode -ExclusionPaths @($TempRoot,'C:\Windows\Temp') -ReenableRealtime
    }
}

# if ($EnableSHIR) {
#     Log-Section "Submodule: SSMS INSTALL (optional)"
#     Enter-DefenderPerfMode -ExclusionPaths @($TempRoot,'C:\Windows\Temp') -DisableRealtime
#     try {
#         Write-Log "-------------------SQL Server Management Studio install starts-----------------------"

#         $step = 'SSMS'
#         $t0 = Get-Date
#         Write-Log "${step}: start at $t0"
#         $codePath = 'C:\Program Files\Microsoft VS SSMS\ssms.exe'
#         $codeExe  = Join-Path $DlDir 'vs_SSMS.exe'
#         if (-not (Test-Path $codePath)) {
#             Write-Log "${step}: download start -> vs_SSMS*.exe"
#             $dlStart = Get-Date
#             Get-PackageByWildcard -Pattern 'vs_SSMS*.exe' -Destination $codeExe
#             $dlEnd = Get-Date
#             Write-Log "${step}: download done at $dlEnd (elapsed $(Format-Duration (New-TimeSpan -Start $dlStart -End $dlEnd))), starting installation"
#             #Start-Process -FilePath $codeExe -ArgumentList '/verysilent /suppressmsgboxes /mergetasks=!runcode' -Wait -WindowStyle Hidden
#         } else { Write-Log "${step}: already present, skipping" }
#         $t1 = Get-Date
#         $span = New-TimeSpan -Start $t0 -End $t1
#         Write-Log "${step}: total $(Format-Duration $span)"
#         Write-Log "${step}: TOTAL $(Format-Minutes $span) min"
#         Write-Log "-------------------SQL Server Management Studio install downloaded but waiting for scheduled.ps1 to complete-----------------------"
#     }
#     catch {
#         Write-Log "ERROR: $_"
#         Write-Log "SQL Server Management Studio installation failed"
#         Exit 1
#     }
#     finally {
#         Exit-DefenderPerfMode -ExclusionPaths @($TempRoot,'C:\Windows\Temp') -ReenableRealtime
#     }
# }


Exit-DefenderPerfMode -ExclusionPaths @($TempRoot,'C:\Windows\Temp') -ReenableRealtime

# ===================================================================
# Finalize
# ===================================================================
Log-Section "Finalize"
Write-Log "Init Script completed."
if ($RebootWhenDone) {
    Write-Log "RebootWhenDone switch is set. Rebooting now..."
    shutdown -r -t 0 -f
} else {
    Write-Log "RebootWhenDone not set. Skipping reboot."
}
Write-Log "===================== Init Script Ends (v1.29) ====================="
