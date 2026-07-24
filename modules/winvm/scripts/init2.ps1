<#
Windows Server 2025 Datacenter bootstrap for Azure VM Custom Script Extension.

Run context:
- Runs as LocalSystem from C:\AzureData\CustomData.bin copied to script.ps1 by Terraform.
- Designed to be idempotent; reruns should converge services, firewall rules, PATH,
  registry settings, shortcuts, scheduled tasks, and installed tools.

Key locations:
- Main log:        $env:ProgramData\Logs\Init\InitLog.txt unless -LogFile is set.
- Workspace:       $env:ProgramData\Bootstrap
- Downloads:       $env:ProgramData\Bootstrap\dl
- Work files:      $env:ProgramData\Bootstrap\work
- Validation tool: $env:ProgramData\Bootstrap\validation.ps1 when present in the scripts container.

Storage inputs:
- packages container: https://<StorageAccount>.blob.core.windows.net/packages/
- scripts container:  https://<StorageAccount>.blob.core.windows.net/scripts/
- localization container: https://<StorageAccount>.blob.core.windows.net/localization/

Primary actions:
- Initialize RAW data disks, enable ICMP, configure OpenSSH, BGInfo, scheduled.ps1,
  set Windows time zone, Azure Arc setup cleanup, secure WinRM, local group membership, and optional SHIR.
- Install/support tools: Az modules, PowerShell 7, Azure CLI, AWS CLI, 7-Zip,
  Git, Terraform, Sysinternals/BGInfo, VS Code, Storage Explorer,
  Azure Data Studio, Postman, MobaXterm, and AzCopy.

Important switches:
- -EnableSHIR: installs/registers Self-hosted Integration Runtime.
- -EnableDefenderPerformanceMode: temporary Defender exclusions during installs.
- -EnableInsecureWinRM: opt-in only; enables Basic auth and unencrypted WinRM.
- -RebootWhenDone: reboots after completion.
- -PackageContainer: blob container that stores installer packages; falls back to packages and scripts.
- -LocalizationContainer: blob container that stores consumer-owned Windows localization scripts.
- -TenantId: optional Entra tenant ID for Az managed identity login when SHIR is enabled.
- -TimeZoneId: Windows time zone ID to apply; defaults to Eastern Standard Time.
#>

param(
  [switch]$EnableSHIR=$false,
  [switch]$EnableDefenderPerformanceMode=$false,
  [string]$LogFile='',
  [Alias('AppRmoteGroup')][string]$AppRemoteGroup='',
  [string]$AppAdminGroup='',
  [string]$Env='dev',
  [switch]$RebootWhenDone=$false,
  [switch]$EnableInsecureWinRM=$false,
  [string]$StorageAccount='stccoeiacccnonprod',
  [string]$PackageContainer='packages',
  [string]$LocalizationContainer='localization',
  [string]$TenantId='',
  [string]$TimeZoneId='Eastern Standard Time'
)

try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12 -bor 3072}catch{}
$SD=$env:SystemDrive;if(-not $SD){$SD='C:'}
$PF=$env:ProgramFiles;if(-not $PF){$PF=Join-Path $SD 'Program Files'}
$PF86=${env:ProgramFiles(x86)};if(-not $PF86){$PF86=Join-Path $SD 'Program Files (x86)'}
$PD=$env:ProgramData;if(-not $PD){$PD=Join-Path $SD 'ProgramData'}
$WD=$env:WINDIR;if(-not $WD){$WD=Join-Path $SD 'Windows'}
$PUB=$env:PUBLIC;if(-not $PUB){$PUB=Join-Path $SD 'Users\Public'}
$TempRoot=Join-Path $PD 'Bootstrap';if(-not $LogFile){$LogFile=Join-Path $PD 'Logs\Init\InitLog.txt'}
$DlDir=Join-Path $TempRoot 'dl';$WorkDir=Join-Path $TempRoot 'work';$LogsDir=Split-Path $LogFile -Parent
$WinTemp=Join-Path $WD 'Temp';$System32=Join-Path $WD 'System32'
$PwshExe=Join-Path $PF 'PowerShell\7\pwsh.exe';$PwshDir=Split-Path $PwshExe -Parent
$AzCliDir=Join-Path $PF86 'Microsoft SDKs\Azure\CLI2\wbin';$AzCliExe=Join-Path $AzCliDir 'az.cmd'
$AwsDir=Join-Path $PF 'Amazon\AWSCLIV2';$AwsExe=Join-Path $AwsDir 'aws.exe'
$SevenZipExe=Join-Path $PF '7-Zip\7z.exe';$GitCmdDir=Join-Path $PF 'Git\cmd';$GitExe=Join-Path $GitCmdDir 'git.exe'
$TerraformDir=$System32;$TerraformExe=Join-Path $TerraformDir 'terraform.exe';$CodeExe=Join-Path $PF 'Microsoft VS Code\Code.exe'
$StorageExplorerExe=Join-Path $PF 'Microsoft Azure Storage Explorer\StorageExplorer.exe';$AdsExe=Join-Path $PF 'Azure Data Studio\azuredatastudio.exe'
$PostmanDir=Join-Path $PF 'Postman';$PostmanExe=Join-Path $PostmanDir 'Postman.exe'
$MobaExe=Join-Path $PF86 'Mobatek\MobaXterm\MobaXterm.exe';$AzCopyDir=Join-Path $PF 'AzCopy';$AzCopyExe=Join-Path $AzCopyDir 'azcopy.exe'
$SshAuthKeys=Join-Path $PD 'ssh\administrators_authorized_keys';$BgInfoCfg=Join-Path $WD 'default.bgi';$BgInfoExe=Join-Path $System32 'Bginfo.exe'
$StartupDir=Join-Path $PD 'Microsoft\Windows\Start Menu\Programs\Startup';$PublicDesktop=Join-Path $PUB 'Desktop'
$BgInfoTaskName='RunBGInfoAtLogon'
$BackgroundWallpaperDir=Join-Path $WD 'Web\Wallpaper\Background';$BackgroundWallpaperPath=Join-Path $BackgroundWallpaperDir 'background.png';$WallpaperApplyScript=Join-Path $TempRoot 'Set-BackgroundWallpaper.ps1';$BgInfoLaunchScript=Join-Path $TempRoot 'Run-BGInfo.ps1'
$DefenderAddedPaths=@();$DefenderAddedProcs=@();$DefenderRealtimeWasDisabled=$null;$ShirMarker=Join-Path $TempRoot 'shir.registered';$ValidationScript=Join-Path $TempRoot 'validation.ps1'
$PackageContainer=if([string]::IsNullOrWhiteSpace($PackageContainer)){'packages'}else{$PackageContainer.Trim()}
$LocalizationContainer=if([string]::IsNullOrWhiteSpace($LocalizationContainer)){'localization'}else{$LocalizationContainer.Trim()}
$PackagesBase="https://$StorageAccount.blob.core.windows.net/$PackageContainer/";$ScriptsBase="https://$StorageAccount.blob.core.windows.net/scripts/"
$sub=switch($Env){'dev'{'nonprod'}'qa'{'nonprod'}'prod'{'prod-001'}default{'sbx'}}

function Mk($p){if($p -and -not(Test-Path -LiteralPath $p)){New-Item -ItemType Directory -Path $p -Force|Out-Null}}
@($TempRoot,$DlDir,$WorkDir,$LogsDir)|%{Mk $_};$env:TEMP=$TempRoot;$env:TMP=$TempRoot
function Log($m){Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $m"}
function Sec($m){Log '----------------------------------------------------------------';Log $m;Log '----------------------------------------------------------------'}
function Remove-PathSafe([string]$Path){
  if([string]::IsNullOrWhiteSpace($Path)){return}
  try{
    if(Test-Path -LiteralPath $Path){Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop}
  }catch{
    Log "WARN: remove $Path : $_"
  }
}
function Remove-ArcShortcut([string]$Path){
  if([string]::IsNullOrWhiteSpace($Path) -or -not(Test-Path -LiteralPath $Path)){return}
  try{
    try{Set-ItemProperty -LiteralPath $Path -Name IsReadOnly -Value $false -ErrorAction SilentlyContinue}catch{}
    Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
    Log "Removed Azure Arc shortcut $Path"
  }catch{
    try{
      $adminSid=New-Object System.Security.Principal.SecurityIdentifier 'S-1-5-32-544'
      $admins=$adminSid.Translate([System.Security.Principal.NTAccount]).Value
      & takeown.exe /F $Path /A | Out-Null
      & icacls.exe $Path /grant "$admins`:F" /inheritance:e | Out-Null
      Remove-Item -LiteralPath $Path -Force -ErrorAction Stop
      Log "Removed Azure Arc shortcut $Path after ACL reset"
    }catch{
      Log "WARN: Azure Arc shortcut removal skipped for $Path : $_"
    }
  }
}
function PkgUrl($n){$PackagesBase+$n}
function ScriptUrl($n){$ScriptsBase+$n}
function Dur($a,$b){$t=New-TimeSpan -Start $a -End $b;"{0:00}h:{1:00}m:{2:00}s" -f [int]$t.TotalHours,$t.Minutes,$t.Seconds}
function CopyDir($src,$dst){
  Mk $dst
  Get-ChildItem -LiteralPath $src -Recurse -Force|%{
    $rel=$_.FullName.Substring($src.Length).TrimStart('\');$to=Join-Path $dst $rel
    if($_.PSIsContainer){Mk $to}else{Mk(Split-Path $to -Parent);try{Copy-Item -LiteralPath $_.FullName -Destination $to -Force -ErrorAction Stop}catch{Log "WARN: copy $($_.FullName): $_"}}
  }
}
function SetWallpaperHive([string]$HiveName,[string]$WallpaperPath){
  if([string]::IsNullOrWhiteSpace($HiveName) -or [string]::IsNullOrWhiteSpace($WallpaperPath) -or -not(Test-Path -LiteralPath $WallpaperPath)){return}
  $desktop="Registry::HKEY_USERS\$HiveName\Control Panel\Desktop"
  try{
    if(-not(Test-Path $desktop)){New-Item -Path $desktop -Force|Out-Null}
    Set-ItemProperty -Path $desktop -Name Wallpaper -Value $WallpaperPath -ErrorAction Stop
    Set-ItemProperty -Path $desktop -Name WallpaperStyle -Value '10' -ErrorAction Stop
    Set-ItemProperty -Path $desktop -Name TileWallpaper -Value '0' -ErrorAction Stop
    Log "Wallpaper registry updated for hive $HiveName"
  }catch{Log "WARN: wallpaper registry hive $HiveName : $_"}
}
function SetProfileWallpaper([string]$ProfileName,[string]$ProfilePath,[string]$WallpaperPath){
  if([string]::IsNullOrWhiteSpace($ProfilePath) -or -not(Test-Path -LiteralPath $ProfilePath)){return}
  $ntUser=Join-Path $ProfilePath 'NTUSER.DAT'
  if(-not(Test-Path -LiteralPath $ntUser)){return}
  $sid=$null
  try{
    $acct=New-Object System.Security.Principal.NTAccount($env:COMPUTERNAME,$ProfileName)
    $sid=$acct.Translate([System.Security.Principal.SecurityIdentifier]).Value
  }catch{}
  if($sid -and (Test-Path "Registry::HKEY_USERS\$sid")){SetWallpaperHive $sid $WallpaperPath;return}
  $mount="Bootstrap_$($ProfileName -replace '[^A-Za-z0-9]','')"
  try{
    & reg.exe load "HKU\$mount" $ntUser|Out-Null
    SetWallpaperHive $mount $WallpaperPath
  }catch{Log "WARN: load profile hive for $ProfileName : $_"}finally{
    try{& reg.exe unload "HKU\$mount"|Out-Null}catch{}
  }
}
function WriteWallpaperApplyScript([string]$Path){
  Mk(Split-Path $Path -Parent)
  @'
param([string]$WallpaperPath='', [string]$LogPath='')
function Write-WallpaperLog([string]$Message){
  if([string]::IsNullOrWhiteSpace($LogPath)){return}
  try{Add-Content -Path $LogPath -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $Message"}catch{}
}
if([string]::IsNullOrWhiteSpace($WallpaperPath) -or -not(Test-Path -LiteralPath $WallpaperPath)){
  Write-WallpaperLog "Wallpaper path missing: $WallpaperPath"
  exit 0
}
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name Wallpaper -Value $WallpaperPath -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10' -ErrorAction SilentlyContinue
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0' -ErrorAction SilentlyContinue
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class WallpaperNative {
  [DllImport("user32.dll", SetLastError=true)]
  public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
$ok=[WallpaperNative]::SystemParametersInfo(20,0,$WallpaperPath,3)
Write-WallpaperLog "SystemParametersInfo wallpaper apply returned $ok for $WallpaperPath"
try{Start-Process rundll32.exe -ArgumentList 'user32.dll,UpdatePerUserSystemParameters' -WindowStyle Hidden -Wait -ErrorAction SilentlyContinue}catch{}
'@ | Set-Content -Path $Path -Encoding ascii -Force
}
function GetHttp($url,$dst,[int]$tries=3){
  # Anonymous HTTPS. This is intentionally kept only for truly public URLs.
  # Do not use this for private Azure Storage accounts.
  Mk(Split-Path $dst -Parent)
  Remove-PathSafe $dst
  $old=$global:ProgressPreference
  $global:ProgressPreference='SilentlyContinue'
  try{
    for($i=1;$i -le $tries;$i++){
      try{
        Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop
        if((Test-Path $dst) -and ((Get-Item $dst).Length -gt 0)){return $true}
        throw "download created missing or empty file: $dst"
      }catch{
        Log "WARN: anonymous http $i $url : $_"
        Start-Sleep -Seconds (5*$i)
      }
    }
  }finally{
    $global:ProgressPreference=$old
  }
  throw "anonymous download failed: $url"
}

$script:StorageAccessToken = $null
$script:StorageAccessTokenExpiresOn = $null
$script:AccessTokens = @{}
$script:AccessTokenExpiresOn = @{}

function GetToken([string]$res='https://storage.azure.com/'){
  if($script:AccessTokens.ContainsKey($res) -and $script:AccessTokenExpiresOn.ContainsKey($res)){
    if((Get-Date).ToUniversalTime().AddMinutes(5) -lt $script:AccessTokenExpiresOn[$res]){
      return $script:AccessTokens[$res]
    }
  }

  $tokenUri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$([uri]::EscapeDataString($res))"

  # If the VM has multiple user-assigned identities, append client_id here:
  # $tokenUri += "&client_id=<USER_ASSIGNED_MANAGED_IDENTITY_CLIENT_ID>"

  $r = Invoke-RestMethod `
    -Method GET `
    -Uri $tokenUri `
    -Headers @{Metadata='true'} `
    -ErrorAction Stop

  if([string]::IsNullOrWhiteSpace($r.access_token)){
    throw "IMDS returned no access_token"
  }

  $script:AccessTokens[$res] = $r.access_token

  try{
    $epoch = [int64]$r.expires_on
    $script:AccessTokenExpiresOn[$res] = [DateTimeOffset]::FromUnixTimeSeconds($epoch).UtcDateTime
  }catch{
    $script:AccessTokenExpiresOn[$res] = (Get-Date).ToUniversalTime().AddMinutes(45)
  }

  $script:StorageAccessToken = $script:AccessTokens['https://storage.azure.com/']
  $script:StorageAccessTokenExpiresOn = $script:AccessTokenExpiresOn['https://storage.azure.com/']

  return $script:AccessTokens[$res]
}

function GetStorageHeaders(){
  @{
    Authorization  = "Bearer $(GetToken)"
    'x-ms-version' = '2020-10-02'
  }
}

function EncodeBlobPath([string]$name){
  (($name -split '/') | ForEach-Object { [uri]::EscapeDataString($_) }) -join '/'
}

function GetKeyVaultSecretMI([string]$VaultName,[string]$SecretName){
  if([string]::IsNullOrWhiteSpace($VaultName)){throw 'Key Vault name is empty'}
  if([string]::IsNullOrWhiteSpace($SecretName)){throw 'Key Vault secret name is empty'}

  $encodedSecretName = [uri]::EscapeDataString($SecretName)
  $uri = "https://$VaultName.vault.azure.net/secrets/$encodedSecretName`?api-version=7.4"

  $response = Invoke-RestMethod `
    -Method GET `
    -Uri $uri `
    -Headers @{Authorization="Bearer $(GetToken 'https://vault.azure.net')"} `
    -ErrorAction Stop

  if([string]::IsNullOrWhiteSpace($response.value)){
    throw "Key Vault secret '$SecretName' in '$VaultName' is empty"
  }

  return [string]$response.value
}

function GetMI($url,$dst,[int]$tries=3){
  Mk(Split-Path $dst -Parent)
  Remove-PathSafe $dst

  for($i=1;$i -le $tries;$i++){
    try{
      Invoke-WebRequest `
        -Method GET `
        -Uri $url `
        -OutFile $dst `
        -Headers (GetStorageHeaders) `
        -UseBasicParsing `
        -ErrorAction Stop

      if((Test-Path $dst) -and ((Get-Item $dst).Length -gt 0)){
        return $true
      }

      throw "download created missing or empty file: $dst"
    }catch{
      $statusCode=$null
      try{$statusCode=[int]$_.Exception.Response.StatusCode}catch{}
      if($statusCode -eq 404 -or "$_" -match 'BlobNotFound|The specified blob does not exist'){
        throw "mi download blob not found: $url"
      }
      Log "WARN: mi download $i $url : $_"
      Start-Sleep -Seconds (5*$i)
    }
  }

  throw "mi download failed: $url"
}

function ConvertResponseToXml($response){
  $xmlText = $null

  try{
    if($response.RawContentStream){
      $response.RawContentStream.Position = 0
      $reader = New-Object System.IO.StreamReader($response.RawContentStream, [Text.Encoding]::UTF8, $true)
      try{
        $xmlText = $reader.ReadToEnd()
      }finally{
        $reader.Dispose()
      }
    }
  }catch{
    $xmlText = $null
  }

  if([string]::IsNullOrWhiteSpace($xmlText)){
    $xmlText = [string]$response.Content
  }

  $xmlText = $xmlText.TrimStart([char]0xFEFF, [char]0x200B)
  $firstXmlChar = $xmlText.IndexOf('<')
  if($firstXmlChar -gt 0){
    $xmlText = $xmlText.Substring($firstXmlChar)
  }
  if($firstXmlChar -lt 0 -or [string]::IsNullOrWhiteSpace($xmlText)){
    throw "response did not contain XML content"
  }

  $x = New-Object System.Xml.XmlDocument
  $x.LoadXml($xmlText)
  return $x
}

function PrefixFromPattern([string]$pattern){
  $idx = $pattern.IndexOfAny([char[]]'*?[')
  if($idx -lt 0){ return $pattern }
  return $pattern.Substring(0,$idx)
}

function ListBlobNamesMI([string]$container,[string]$prefix=''){
  if([string]::IsNullOrWhiteSpace($StorageAccount)){
    throw "StorageAccount parameter is empty"
  }
  if([string]::IsNullOrWhiteSpace($container)){
    throw "container parameter is empty"
  }

  $all = @()
  $marker = $null

  do {
    $uri = "https://$StorageAccount.blob.core.windows.net/${container}?restype=container&comp=list"

    if(-not [string]::IsNullOrWhiteSpace($prefix)){
      $uri += "&prefix=$([uri]::EscapeDataString($prefix))"
    }

    if(-not [string]::IsNullOrWhiteSpace($marker)){
      $uri += "&marker=$([uri]::EscapeDataString($marker))"
    }

    try{
      $response = Invoke-WebRequest `
        -Method GET `
        -Uri $uri `
        -Headers (GetStorageHeaders) `
        -UseBasicParsing `
        -ErrorAction Stop
      $x = ConvertResponseToXml $response
    }catch{
      throw "blob list failed: account=$StorageAccount container=$container prefix='$prefix' uri=$uri error=$($_.Exception.Message)"
    }

    if($x.EnumerationResults.Blobs.Blob){
      $all += @(
        $x.EnumerationResults.Blobs.Blob | ForEach-Object {
          [pscustomobject]@{
            Name         = [string]$_.Name
            LastModified = [datetime]$_.Properties.'Last-Modified'
          }
        }
      )
    }

    $marker = [string]$x.EnumerationResults.NextMarker
  } while (-not [string]::IsNullOrWhiteSpace($marker))

  return $all
}

function BlobName($container,$pattern){
  $prefix = PrefixFromPattern $pattern

  $matches = @(
    ListBlobNamesMI $container $prefix |
      Where-Object { $_.Name -like $pattern }
  )

  if(-not $matches -or $matches.Count -eq 0){
    throw "no blob matched: account=$StorageAccount container=$container pattern=$pattern prefix=$prefix"
  }

  return (
    $matches |
      Sort-Object LastModified -Descending |
      Select-Object -First 1
  ).Name
}

function GetBlob($container,$name,$dst){
  $encodedName = EncodeBlobPath $name
  $url = "https://$StorageAccount.blob.core.windows.net/$container/$encodedName"
  Log "MI REST download account=$StorageAccount container=$container blob=$name"
  GetMI $url $dst | Out-Null
}

function GetPkg($pattern,$dst){
  $containers = @()

  if(-not [string]::IsNullOrWhiteSpace($PackageContainer)){
    $containers += $PackageContainer
  }

  # Keep scripts as fallback only because some older bootstrap layouts stored packages there.
  if($containers -notcontains 'packages'){ $containers += 'packages' }
  if($containers -notcontains 'scripts'){ $containers += 'scripts' }

  $errors = @()

  foreach($c in $containers){
    try{
      $n = BlobName $c $pattern
      Log "MI REST package matched account=$StorageAccount container=$c blob=$n"
      GetBlob $c $n $dst
      return
    }catch{
      $errors += "${c}: $($_.Exception.Message)"
      Log "WARN: package lookup failed in $c for $pattern : $_"
    }
  }

  throw "package blob not found for pattern '$pattern'. Tried containers: $($containers -join ', '). Details: $($errors -join ' | ')"
}

function GetPkgAny($patterns,$dst){
  $errors=@()

  foreach($pattern in @($patterns)){
    try{
      GetPkg $pattern $dst
      return
    }catch{
      $errors += "${pattern}: $($_.Exception.Message)"
      Log "WARN: package pattern failed for $pattern : $_"
    }
  }

  throw "package blob not found for any pattern. Tried patterns: $(@($patterns) -join ', '). Details: $($errors -join ' | ')"
}

function GetScript($name,$dst){
  GetBlob scripts $name $dst
}

function TryGetScript($name,$dst){
  try{
    GetScript $name $dst
    return (Test-Path $dst)
  }catch{
    Log "WARN: optional script not found or not accessible: scripts/$name : $_"
    return $false
  }
}

function RunMsi($name,$msi,[int]$tries=5){
  for($i=1;$i -le $tries;$i++){
    $p=Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru -WindowStyle Hidden
    if($p.ExitCode -in 0,3010,1641){return $p.ExitCode}
    if($p.ExitCode -eq 1618 -and $i -lt $tries){
      $wait=30*$i
      Log "WARN: $name MSI exit 1618; another installation is in progress. Retry $($i+1)/$tries in ${wait}s"
      Start-Sleep -Seconds $wait
      continue
    }
    throw "$name MSI exit $($p.ExitCode)"
  }
}
function MSI($name,$pattern,$detect){
  Sec "Install: $name";$t=Get-Date
  if($detect -and (Test-Path $detect)){Log "$name already present";return}
  $msi = Join-Path $DlDir (($name -replace '[^A-Za-z0-9]', '') + '.msi')
  GetPkg $pattern $msi
  RunMsi $name $msi|Out-Null
  if($detect -and -not(Test-Path $detect)){throw "$name install did not create expected path: $detect"}
  Log "$name done $(Dur $t (Get-Date))"
}
function EXE($name,$pattern,$detect,$InstallArgs){
  Sec "Install: $name";$t=Get-Date
  if($detect -and (Test-Path $detect)){Log "$name already present";return}
  $exe=Join-Path $DlDir (($name -replace '[^A-Za-z0-9]','')+'.exe')
  GetPkg $pattern $exe
  $p=Start-Process -FilePath $exe -ArgumentList $InstallArgs -Wait -PassThru -WindowStyle Hidden
  if($p.ExitCode -notin 0,3010,1641){Log "WARN: $name installer exit $($p.ExitCode)"}
  if($detect -and -not(Test-Path $detect)){throw "$name install did not create expected path: $detect"}
  Log "$name done $(Dur $t (Get-Date))"
}
function EXEAny($name,$patterns,$detect,$InstallArgs){
  Sec "Install: $name";$t=Get-Date
  if($detect -and (Test-Path $detect)){Log "$name already present";return}
  $exe=Join-Path $DlDir (($name -replace '[^A-Za-z0-9]','')+'.exe')
  GetPkgAny $patterns $exe
  $p=Start-Process -FilePath $exe -ArgumentList $InstallArgs -Wait -PassThru -WindowStyle Hidden
  if($p.ExitCode -notin 0,3010,1641){Log "WARN: $name installer exit $($p.ExitCode)"}
  if($detect -and -not(Test-Path $detect)){throw "$name install did not create expected path: $detect"}
  Log "$name done $(Dur $t (Get-Date))"
}
function TerraformZip($pattern){
  Sec 'Install: Terraform';$t=Get-Date
  if(Test-Path $TerraformExe){Log 'Terraform already present';return}
  $zip=Join-Path $DlDir 'terraform.zip';$ext=Join-Path $WorkDir 'terraform_extracted'
  GetPkg $pattern $zip
  Remove-PathSafe $ext
  Expand-Archive -Path $zip -DestinationPath $ext -Force
  $f=Get-ChildItem -LiteralPath $ext -Recurse -Filter terraform.exe -ErrorAction SilentlyContinue|Select-Object -First 1
  if(-not $f){throw 'terraform.exe not found in package'}
  Copy-Item -LiteralPath $f.FullName -Destination $TerraformExe -Force
  if(-not(Test-Path $TerraformExe)){throw "Terraform install did not create expected path: $TerraformExe"}
  try{Log "Terraform version: $(& $TerraformExe -version | Select-Object -First 1)"}catch{Log "WARN: Terraform verification: $_"}
  Log "Terraform done $(Dur $t (Get-Date))"
}
function InstallAzModulesPs51{
  Sec 'Az Modules PS 5.1';$t=Get-Date
  $azAccounts=Join-Path $PF 'WindowsPowerShell\Modules\Az.Accounts'
  $ps51Modules=Join-Path $PF 'WindowsPowerShell\Modules'
  $zip=Join-Path $DlDir 'az-modules.zip'
  $ext=Join-Path $WorkDir 'azmods_extracted'
  if(Test-Path $azAccounts){
    Log 'Az.Accounts already present for Windows PowerShell 5.1'
  }else{
    GetPkg 'az-modules.zip' $zip
    Remove-PathSafe $ext
    Expand-Archive -Path $zip -DestinationPath $ext -Force
    Mk $ps51Modules
    $mods=Get-ChildItem -LiteralPath $ext -Directory -ErrorAction SilentlyContinue
    if(-not $mods){throw "No Az module folders found in $ext"}
    $mods|%{CopyDir $_.FullName (Join-Path $ps51Modules $_.Name)}
    if(-not(Test-Path $azAccounts)){throw "Az.Accounts install did not create expected path: $azAccounts"}
  }
  try{Import-Module Az.Accounts -ErrorAction Stop;Log 'Az.Accounts imported for Windows PowerShell 5.1'}catch{Log "WARN: Az.Accounts import: $_"}
  Log "Az Modules PS 5.1 done $(Dur $t (Get-Date))"
}
function CopyAzModulesToPs7{
  Sec 'Az Modules PS 7 Copy';$t=Get-Date
  $ps51Modules=Join-Path $PF 'WindowsPowerShell\Modules'
  $ps7Modules=Join-Path $PF 'PowerShell\7\Modules'
  if(-not(Test-Path $PwshExe)){Log "WARN: PowerShell 7 not found at $PwshExe; skipping Az module copy";return}
  Mk $ps7Modules
  $mods=Get-ChildItem -LiteralPath $ps51Modules -Directory -ErrorAction SilentlyContinue|?{$_.Name -like 'Az*'}
  if(-not $mods){Log "WARN: No Az modules found in $ps51Modules; skipping PS 7 copy";return}
  $mods|%{CopyDir $_.FullName (Join-Path $ps7Modules $_.Name)}
  try{& $PwshExe -NoProfile -Command "Import-Module Az.Accounts -ErrorAction Stop; (Get-Module Az.Accounts).Version.ToString()"|%{Log "Az.Accounts PS 7 import version: $_"}}catch{Log "WARN: Az.Accounts PS 7 import: $_"}
  Log "Az Modules PS 7 Copy done $(Dur $t (Get-Date))"
}
function InstallSysinternals{
  Sec 'Sysinternals';$t=Get-Date
  if(Test-Path $BgInfoExe){Log "BGInfo already present at $BgInfoExe";return}
  $zip=Join-Path $DlDir 'SysinternalsSuite.zip'
  GetPkg 'SysinternalsSuite*.zip' $zip
  Expand-Archive -Path $zip -DestinationPath $System32 -Force
  if(-not(Test-Path $BgInfoExe)){throw "Sysinternals install did not create expected path: $BgInfoExe"}
  try{Unblock-File (Join-Path $System32 '*.exe') -ErrorAction SilentlyContinue}catch{}
  Log "Sysinternals done $(Dur $t (Get-Date))"
}
function InstallBgInfoStandalone{
  Sec 'Install: BGInfo standalone';$t=Get-Date
  if(Test-Path $BgInfoExe){Log "BGInfo already present at $BgInfoExe";return}
  $src=Join-Path $DlDir 'Bginfo.exe'
  GetPkgAny @('Bginfo*.exe','BGInfo*.exe','BGInfo64*.exe') $src
  Copy-Item -LiteralPath $src -Destination $BgInfoExe -Force
  if(-not(Test-Path $BgInfoExe)){throw "BGInfo standalone install did not create expected path: $BgInfoExe"}
  try{Unblock-File $BgInfoExe -ErrorAction SilentlyContinue}catch{}
  Log "BGInfo standalone done $(Dur $t (Get-Date))"
}
function EnsureFirewallRule($Name,$DisplayName,$Protocol,$LocalPort=$null){
  $r=Get-NetFirewallRule -Name $Name -ErrorAction SilentlyContinue
  if(-not $r){$r=Get-NetFirewallRule -DisplayName $DisplayName -ErrorAction SilentlyContinue|Select-Object -First 1}
  if($r){$r|Set-NetFirewallRule -Enabled True -Action Allow -ErrorAction Stop|Out-Null;return}
  $args=@{Name=$Name;DisplayName=$DisplayName;Enabled='True';Action='Allow';Protocol=$Protocol}
  if($LocalPort){$args.LocalPort=$LocalPort;New-NetFirewallRule @args -Direction Inbound|Out-Null}else{New-NetFirewallRule @args|Out-Null}
}
function AddLocalMember($GroupName,$Member){
  if([string]::IsNullOrWhiteSpace($Member)){return}
  if($Member -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'){
    Log "WARN: Skipping '$Member' for local group '$GroupName'; Windows needs a resolvable account name or SID, not an Azure AD object ID"
    return
  }
  try{
    $existing=Get-LocalGroupMember -Group $GroupName -ErrorAction Stop|?{$_.Name -ieq $Member -or $_.SID.Value -ieq $Member}
    if($existing){Log "Local group '$GroupName' already contains '$Member'";return}
    Add-LocalGroupMember -Group $GroupName -Member $Member -ErrorAction Stop
    $added=Get-LocalGroupMember -Group $GroupName -ErrorAction Stop|?{$_.Name -ieq $Member -or $_.SID.Value -ieq $Member}
    if($added){Log "Added '$Member' to local group '$GroupName'"}else{Log "WARN: Add-LocalGroupMember returned but '$Member' was not found in '$GroupName'"}
  }catch{Log "WARN: Could not add '$Member' to local group '$GroupName': $_"}
}
function FindPostmanInstall{
  $c=@((Join-Path $WD 'System32\config\systemprofile\AppData\Local\Postman'),(Join-Path $WD 'SysWOW64\config\systemprofile\AppData\Local\Postman'))
  if($env:LOCALAPPDATA){$c+=(Join-Path $env:LOCALAPPDATA 'Postman')}
  $users=Join-Path $SD 'Users'
  if(Test-Path $users){$c+=Get-ChildItem $users -Directory -ErrorAction SilentlyContinue|%{Join-Path $_.FullName 'AppData\Local\Postman'}}
  foreach($p in ($c|Select-Object -Unique)){if((Test-Path (Join-Path $p 'Postman.exe')) -or (Get-ChildItem $p -Recurse -Filter Postman.exe -ErrorAction SilentlyContinue|Select-Object -First 1)){return $p}}
  return $null
}
function AddPath($items){
  $cur=[Environment]::GetEnvironmentVariable('Path','Machine')
  $parts=@($cur -split ';'|?{$_});$norm=@{}
  $parts|%{$norm[$_.TrimEnd('\').ToLowerInvariant()]=$true}
  $changed=$false
  foreach($i in $items){
    if(-not $i){continue}
    $k=$i.TrimEnd('\').ToLowerInvariant()
    if(-not $norm.ContainsKey($k)){$parts+=$i;$norm[$k]=$true;$changed=$true}
  }
  if($changed){$cur=($parts -join ';');[Environment]::SetEnvironmentVariable('Path',$cur,'Machine')}
  $env:Path=[Environment]::GetEnvironmentVariable('Path','Machine')+';'+[Environment]::GetEnvironmentVariable('Path','User')
}
function DefOn{
  if(-not $EnableDefenderPerformanceMode -or -not(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue)){return}
  try{
    $pref=Get-MpPreference -ErrorAction SilentlyContinue
    if($null -eq $script:DefenderRealtimeWasDisabled){$script:DefenderRealtimeWasDisabled=[bool]$pref.DisableRealtimeMonitoring}
    @($TempRoot,$WinTemp)|%{if((Test-Path $_) -and ($pref.ExclusionPath -notcontains $_)){Add-MpPreference -ExclusionPath $_ -ErrorAction SilentlyContinue;$script:DefenderAddedPaths+=$_}}
    @('msiexec.exe','powershell.exe','pwsh.exe')|%{if($pref.ExclusionProcess -notcontains $_){Add-MpPreference -ExclusionProcess $_ -ErrorAction SilentlyContinue;$script:DefenderAddedProcs+=$_}}
    Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue;Log 'Defender perf mode on'
  }catch{Log "WARN: Defender on: $_"}
}
function DefOff{
  if(-not $EnableDefenderPerformanceMode -or -not(Get-Command Get-MpComputerStatus -ErrorAction SilentlyContinue)){return}
  try{
    $script:DefenderAddedPaths|Select-Object -Unique|%{Remove-MpPreference -ExclusionPath $_ -ErrorAction SilentlyContinue}
    $script:DefenderAddedProcs|Select-Object -Unique|%{Remove-MpPreference -ExclusionProcess $_ -ErrorAction SilentlyContinue}
    Set-MpPreference -DisableRealtimeMonitoring $script:DefenderRealtimeWasDisabled -ErrorAction SilentlyContinue;Log 'Defender perf mode off'
  }catch{Log "WARN: Defender off: $_"}
}

Log '===================== Init Script Starts v2.0 compact ====================='
Log "Env=$Env Storage=$StorageAccount Temp=$TempRoot"
$AppRemoteGroupArray=@();$AppAdminGroupArray=@()
if($AppRemoteGroup){$AppRemoteGroupArray=$AppRemoteGroup -split ','|%{$_.Trim()}|?{$_}}
if($AppAdminGroup){$AppAdminGroupArray=$AppAdminGroup -split ','|%{$_.Trim()}|?{$_}}

Sec 'Time Zone'
try{
  if([string]::IsNullOrWhiteSpace($TimeZoneId)){
    Log 'TimeZoneId is empty; skipping time zone configuration'
  }else{
    $currentTimeZone = Get-TimeZone -ErrorAction Stop
    if($currentTimeZone.Id -ieq $TimeZoneId){
      Log "Time zone already set to '$TimeZoneId'"
    }else{
      Set-TimeZone -Id $TimeZoneId -ErrorAction Stop
      $updatedTimeZone = Get-TimeZone -ErrorAction Stop
      Log "Time zone changed from '$($currentTimeZone.Id)' to '$($updatedTimeZone.Id)'"
    }
  }
}catch{Log "WARN: time zone: $_"}

Sec 'Enable Ping'
try{EnsureFirewallRule 'Allow-ICMPv4-In' 'Allow ICMPv4-In' 'ICMPv4'}catch{Log "WARN: ICMP: $_"}

Sec 'Initialize RAW Disks'
try{
  Get-Disk|?{$_.PartitionStyle -eq 'RAW' -and -not $_.IsBoot -and -not $_.IsSystem}|%{
    $d=Initialize-Disk -Number $_.Number -PartitionStyle GPT -PassThru
    $p=New-Partition -DiskNumber $d.Number -AssignDriveLetter -UseMaximumSize
    Format-Volume -Partition $p -FileSystem NTFS -NewFileSystemLabel "Data$($d.Number)" -Confirm:$false|Out-Null
    Log "Disk $($d.Number) formatted"
  }
}catch{Log "WARN: disk init: $_"}

DefOn
try{
  Sec 'Az Modules PS 5.1'
  Log 'Az Modules PS 5.1 install disabled; package download from storage is too slow'

  Sec 'Azure Managed Identity Login'
  Log 'Az module login skipped; storage and Key Vault bootstrap use direct IMDS REST tokens'

  MSI 'PowerShell7' 'PowerShell-*-win-x64.msi' $PwshExe
  Sec 'Az Modules PS 7 Copy'
  Log 'Az Modules PS 7 copy disabled because Az Modules PS 5.1 install is disabled'

  MSI 'AzureCLI' 'azure-cli-*.msi' $AzCliExe
  Sec 'Install: AWSCLI'
  Log 'AWSCLI install temporarily disabled'
  MSI '7Zip' '7z*-x64.msi' $SevenZipExe
  Sec 'Install: Git'
  Log 'Git install disabled; package download from storage is too slow'
  Sec 'Install: Terraform'
  Log 'Terraform install disabled; package download from storage is too slow'

  Sec 'Sysinternals'
  Log 'Sysinternals Suite install temporarily disabled; BGInfo uses standalone package from storage'
  InstallBgInfoStandalone

  Sec 'Install: VSCode'
  Log 'VSCode install temporarily disabled'
  Sec 'Install: StorageExplorer'
  Log 'StorageExplorer install disabled; package download from storage is too slow'
  Sec 'Install: AzureDataStudio'
  Log 'AzureDataStudio install temporarily disabled'

  Sec 'Postman'
  Log 'Postman install temporarily disabled'

  Sec 'MobaXterm'
  Log 'MobaXterm install temporarily disabled'

  Sec 'AzCopy'
  Log 'AzCopy install temporarily disabled'
}catch{Log "ERROR: software install failed: $_";Exit 1}finally{DefOff}

Sec 'PATH Updates'
try{
  AddPath @($AzCliDir,$PwshDir,$GitCmdDir,$TerraformDir)
}catch{Log "WARN: PATH: $_"}

Sec 'OpenSSH Server'
try{
  # Windows Server 2025 includes OpenSSH Server by default; configure only.
  if(-not(Get-Service sshd -ErrorAction SilentlyContinue)){Log 'WARN: sshd service not present; skipping capability install for Server 2025 base image'}else{
    Set-Service sshd -StartupType Automatic
    if((Get-Service sshd).Status -ne 'Running'){Start-Service sshd}
  }
  EnsureFirewallRule 'OpenSSH-Server-In-TCP' 'OpenSSH-Server-In-TCP' 'TCP' 22
  $ak=$SshAuthKeys;Mk(Split-Path $ak -Parent);$tmp=Join-Path $DlDir 'azureadmin-pubkey'
  try{GetScript 'azureadmin-pubkey' $tmp;$key=Get-Content $tmp -ErrorAction SilentlyContinue|Select-Object -First 1;if($key){Set-Content -Path $ak -Value $key -Encoding ascii -Force;icacls $ak /inheritance:r|Out-Null;icacls $ak /grant:r 'Administrators:F' /grant:r 'SYSTEM:F'|Out-Null;icacls $ak /remove 'NT AUTHORITY\Authenticated Users'|Out-Null}}catch{Log "WARN: ssh key: $_"}
}catch{Log "WARN: OpenSSH: $_"}

Sec 'BGInfo'
try{
  if(-not(Test-Path $BgInfoExe)){throw "BGInfo executable not found at $BgInfoExe after Sysinternals install"}
  $cfg=$BgInfoCfg;GetScript 'default.bgi' $cfg
  Mk $BackgroundWallpaperDir
  try{
    GetScript 'background.png' $BackgroundWallpaperPath
    try{Unblock-File $BackgroundWallpaperPath -ErrorAction SilentlyContinue}catch{}
  }catch{
    Log "WARN: optional BGInfo background.png was not staged: $_"
  }
  SetProfileWallpaper 'Default' (Join-Path $SD 'Users\Default') $BackgroundWallpaperPath
  SetProfileWallpaper 'azureadmin' (Join-Path $SD 'Users\azureadmin') $BackgroundWallpaperPath
  WriteWallpaperApplyScript $WallpaperApplyScript
  @'
param(
  [string]$WallpaperScript='',
  [string]$WallpaperPath='',
  [string]$BgInfoExe='',
  [string]$BgInfoConfig='',
  [string]$LogPath=''
)
function Write-BgInfoLog([string]$Message){
  if([string]::IsNullOrWhiteSpace($LogPath)){return}
  try{Add-Content -Path $LogPath -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $Message"}catch{}
}
if($WallpaperScript -and (Test-Path -LiteralPath $WallpaperScript)){
  & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $WallpaperScript -WallpaperPath $WallpaperPath -LogPath $LogPath
}else{
  Write-BgInfoLog "Wallpaper script missing: $WallpaperScript"
}
if($BgInfoExe -and $BgInfoConfig -and (Test-Path -LiteralPath $BgInfoExe) -and (Test-Path -LiteralPath $BgInfoConfig)){
  & $BgInfoExe $BgInfoConfig /timer:0 /silent /nolicprompt
  Write-BgInfoLog "BGInfo exit code $LASTEXITCODE for $BgInfoExe $BgInfoConfig"
  Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name WallpaperStyle -Value '10' -ErrorAction SilentlyContinue
  Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name TileWallpaper -Value '0' -ErrorAction SilentlyContinue
  try{
    $wallpaperState=Get-ItemProperty 'HKCU:\Control Panel\Desktop' Wallpaper,WallpaperStyle,TileWallpaper -ErrorAction Stop
    Write-BgInfoLog "Wallpaper final state: Wallpaper=$($wallpaperState.Wallpaper) WallpaperStyle=$($wallpaperState.WallpaperStyle) TileWallpaper=$($wallpaperState.TileWallpaper)"
  }catch{Write-BgInfoLog "Wallpaper final state read failed: $_"}
}else{
  Write-BgInfoLog "BGInfo missing input exe=$BgInfoExe config=$BgInfoConfig"
}
'@ | Set-Content -Path $BgInfoLaunchScript -Encoding ascii -Force
  Mk $StartupDir
  $bgLog=Join-Path $TempRoot 'BGInfoUser.log'
  $bgArgs="-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File `"$BgInfoLaunchScript`" -WallpaperScript `"$WallpaperApplyScript`" -WallpaperPath `"$BackgroundWallpaperPath`" -BgInfoExe `"$BgInfoExe`" -BgInfoConfig `"$cfg`" -LogPath `"$bgLog`""
  $lnk=Join-Path $StartupDir 'BGInfo.lnk';$sh=New-Object -ComObject WScript.Shell;$sc=$sh.CreateShortcut($lnk)
  $sc.TargetPath='powershell.exe';$sc.Arguments=$bgArgs;$sc.Save()
  $azureAdminStartup=Join-Path $SD 'Users\azureadmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup'
  if(Test-Path (Join-Path $SD 'Users\azureadmin')){
    Mk $azureAdminStartup
    $userLnk=Join-Path $azureAdminStartup 'BGInfo.lnk';$usc=$sh.CreateShortcut($userLnk)
    $usc.TargetPath='powershell.exe';$usc.Arguments=$bgArgs;$usc.Save()
    Log "BGInfo azureadmin startup shortcut configured: $userLnk"
  }else{
    Log 'azureadmin profile folder not found; relying on common Startup shortcut and scheduled task'
  }
  $bgAct=New-ScheduledTaskAction -Execute 'powershell.exe' -Argument $bgArgs
  $bgTrg=New-ScheduledTaskTrigger -AtLogOn
  $bgSet=New-ScheduledTaskSettingsSet -ExecutionTimeLimit (New-TimeSpan -Minutes 5) -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
  $azureAdminTaskUser="$env:COMPUTERNAME\azureadmin"
  try{$bgPrn=New-ScheduledTaskPrincipal -UserId $azureAdminTaskUser -LogonType Interactive -RunLevel Highest}catch{$bgPrn=New-ScheduledTaskPrincipal -GroupId 'BUILTIN\Users' -RunLevel Highest}
  Register-ScheduledTask -TaskName $BgInfoTaskName -Action $bgAct -Trigger $bgTrg -Principal $bgPrn -Settings $bgSet -Force|Out-Null
  try{
    $registered=Get-ScheduledTask -TaskName $BgInfoTaskName -ErrorAction Stop
    Log "BGInfo scheduled task registered for principal '$($registered.Principal.UserId)$($registered.Principal.GroupId)'"
  }catch{Log "WARN: BGInfo task verification: $_"}
  Log "BGInfo configured: shortcut=$lnk task=$BgInfoTaskName exe=$BgInfoExe cfg=$cfg wallpaper=$BackgroundWallpaperPath"
}catch{Log "ERROR: BGInfo: $_";Exit 1}

Sec 'Scheduled Task'
try{
  $sched=Join-Path $WorkDir 'scheduled.ps1';GetScript 'scheduled.ps1' $sched;Unblock-File $sched -ErrorAction SilentlyContinue
  if(-not(Test-Path -LiteralPath $sched)){throw "scheduled.ps1 was not staged at $sched"}
  try{
    $schedItem=Get-Item -LiteralPath $sched -ErrorAction Stop
    $schedHash=(Get-FileHash -LiteralPath $sched -Algorithm SHA256 -ErrorAction Stop).Hash
    Log "post-cloud-init script staged: path=$sched bytes=$($schedItem.Length) sha256=$schedHash"
  }catch{
    Log "WARN: post-cloud-init staged script metadata failed: $_"
  }
  $schedArgs="-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `"$sched`" -StorageAccount `"$StorageAccount`" -PackageContainer `"$PackageContainer`" -LocalizationContainer `"$LocalizationContainer`" -VMName `"$env:COMPUTERNAME`" -LogFile `"$LogFile`""
  if($EnableDefenderPerformanceMode){$schedArgs+=' -EnableDefenderPerformanceMode'}
  Log "post-cloud-init action: powershell.exe $schedArgs"
  $taskXml=@"
<?xml version="1.0" encoding="UTF-16"?>
<Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
  <RegistrationInfo>
    <Date>$((Get-Date).ToString('s'))</Date>
    <Author>winvm init2.ps1</Author>
    <Description>Run scheduled.ps1 as SYSTEM 5 minutes after boot when no users are logged on.</Description>
  </RegistrationInfo>
  <Triggers>
    <BootTrigger>
      <Enabled>true</Enabled>
      <Delay>PT5M</Delay>
    </BootTrigger>
  </Triggers>
  <Principals>
    <Principal id="Author">
      <UserId>S-1-5-18</UserId>
      <RunLevel>HighestAvailable</RunLevel>
    </Principal>
  </Principals>
  <Settings>
    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>
    <DisallowStartIfOnBatteries>false</DisallowStartIfOnBatteries>
    <StopIfGoingOnBatteries>false</StopIfGoingOnBatteries>
    <AllowHardTerminate>true</AllowHardTerminate>
    <StartWhenAvailable>true</StartWhenAvailable>
    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>
    <AllowStartOnDemand>true</AllowStartOnDemand>
    <Enabled>true</Enabled>
    <Hidden>false</Hidden>
    <RunOnlyIfIdle>false</RunOnlyIfIdle>
    <ExecutionTimeLimit>PT4H</ExecutionTimeLimit>
    <Priority>7</Priority>
  </Settings>
  <Actions Context="Author">
    <Exec>
      <Command>powershell.exe</Command>
      <Arguments>$([Security.SecurityElement]::Escape($schedArgs))</Arguments>
    </Exec>
  </Actions>
</Task>
"@
  $taskXmlPath=Join-Path $WorkDir 'post-cloud-init.xml'
  Set-Content -Path $taskXmlPath -Value $taskXml -Encoding Unicode -Force
  Log "post-cloud-init XML staged: $taskXmlPath"
  try{
    [xml]$null=$taskXml
    Log 'post-cloud-init XML parse check passed'
  }catch{
    throw "post-cloud-init XML parse check failed: $_"
  }
  try{
    Register-ScheduledTask -TaskName 'post-cloud-init' -Xml $taskXml -Force -ErrorAction Stop|Out-Null
    Log 'post-cloud-init Register-ScheduledTask completed'
  }catch{
    Log "WARN: Register-ScheduledTask failed for post-cloud-init: $_"
    $p=Start-Process schtasks.exe -ArgumentList '/Create','/TN','post-cloud-init','/XML',$taskXmlPath,'/F' -Wait -PassThru -WindowStyle Hidden
    if($p.ExitCode -ne 0){throw "schtasks.exe fallback failed for post-cloud-init with exit $($p.ExitCode)"}
    Log 'post-cloud-init schtasks.exe fallback completed'
  }
  $registered=Get-ScheduledTask -TaskName 'post-cloud-init' -ErrorAction Stop
  $registeredInfo=Get-ScheduledTaskInfo -TaskName 'post-cloud-init' -ErrorAction SilentlyContinue
  $actionSummary=($registered.Actions|%{"$($_.Execute) $($_.Arguments)"}) -join ' | '
  $triggerSummary=($registered.Triggers|%{$_.CimClass.CimClassName}) -join ','
  Log "post-cloud-init verified: state=$($registered.State) principalUser=$($registered.Principal.UserId) logonType=$($registered.Principal.LogonType) runLevel=$($registered.Principal.RunLevel) triggers=$triggerSummary"
  Log "post-cloud-init verified action: $actionSummary"
  if($registered.Settings){
    Log "post-cloud-init verified settings: runOnlyIfIdle=$($registered.Settings.RunOnlyIfIdle) executionTimeLimit=$($registered.Settings.ExecutionTimeLimit)"
  }
  if($registeredInfo){
    Log "post-cloud-init info: lastRun=$($registeredInfo.LastRunTime) lastResult=$($registeredInfo.LastTaskResult) nextRun=$($registeredInfo.NextRunTime) missedRuns=$($registeredInfo.NumberOfMissedRuns)"
  }
  Log 'post-cloud-init registered: trigger=boot-delay-5m, no-user-session guard in scheduled.ps1, principal=SYSTEM'
}catch{Log "ERROR: scheduled task: $_";Exit 1}

Sec 'Validation Tool'
if(TryGetScript 'validation.ps1' $ValidationScript){
  Unblock-File $ValidationScript -ErrorAction SilentlyContinue
  Log "Validation script available at $ValidationScript"
}else{Log 'Validation script not found in scripts container; continuing without VM-side validation tool'}

Sec 'Azure Arc Cleanup'
try{
  $sm='HKLM:\SOFTWARE\Microsoft\ServerManager';$pol='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  if(-not(Test-Path $sm)){New-Item -Path $sm -Force|Out-Null}
  Set-ItemProperty -Path $sm -Name DoNotPopulateAzureArcTiles -Type DWord -Value 1 -ErrorAction Stop
  if(-not(Test-Path $pol)){New-Item -Path $pol -Force|Out-Null}
  Set-ItemProperty -Path $pol -Name DisableAzureArcSetup -Type DWord -Value 1 -ErrorAction Stop
  @(
    (Join-Path $PD 'Microsoft\Windows\Start Menu\Programs\Azure Arc Setup.lnk'),
    (Join-Path $PD 'Microsoft\Windows\Start Menu\Programs\Azure Arc.lnk'),
    (Join-Path $PUB 'Desktop\Azure Arc Setup.lnk')
  )|Select-Object -Unique|%{Remove-ArcShortcut $_}
  Get-ChildItem -LiteralPath (Join-Path $PD 'Microsoft\Windows\Start Menu\Programs') -Recurse -Filter '*Azure Arc*.lnk' -ErrorAction SilentlyContinue|Select-Object -ExpandProperty FullName -Unique|%{Remove-ArcShortcut $_}
  Get-ScheduledTask -ErrorAction SilentlyContinue|?{$_.TaskName -like '*AzureArc*' -or $_.TaskName -like '*Azure Arc*'}|%{
    try{Unregister-ScheduledTask -TaskName $_.TaskName -TaskPath $_.TaskPath -Confirm:$false -ErrorAction Stop;Log "Removed Azure Arc scheduled task $($_.TaskPath)$($_.TaskName)"}catch{Log "WARN: Azure Arc scheduled task cleanup $($_.TaskName): $_"}
  }
  $cap=Get-WindowsCapability -Online -Name 'AzureArcSetup~~~~' -ErrorAction SilentlyContinue
  if($cap -and $cap.State -ne 'NotPresent'){
    try{
      Remove-WindowsCapability -Online -Name 'AzureArcSetup~~~~' -ErrorAction Stop|Out-Null
      Log 'AzureArcSetup capability removal requested with Remove-WindowsCapability'
    }catch{
      Log "WARN: Remove-WindowsCapability AzureArcSetup failed: $_. Trying DISM fallback."
      $p=Start-Process dism.exe -ArgumentList '/Online','/Remove-Capability','/CapabilityName:AzureArcSetup~~~~','/NoRestart' -Wait -PassThru -WindowStyle Hidden
      if($p.ExitCode -notin 0,3010){Log "WARN: AzureArcSetup DISM removal exit $($p.ExitCode)"}else{Log 'AzureArcSetup capability removed or pending restart'}
    }
  }else{Log 'AzureArcSetup capability not installed'}
  Log 'Azure Arc surfacing cleanup completed'
}catch{Log "WARN: Arc cleanup: $_"}

Sec 'WinRM'
try{
  Enable-PSRemoting -Force -SkipNetworkProfileCheck|Out-Null
  winrm set winrm/config/service '@{AllowUnencrypted="false"}'|Out-Null
  winrm set winrm/config/service/auth '@{Basic="false"}'|Out-Null
  if($EnableInsecureWinRM){
    Log 'WARN: EnableInsecureWinRM set; enabling Basic auth and unencrypted WinRM'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'|Out-Null
    winrm set winrm/config/service/auth '@{Basic="true"}'|Out-Null
  }
  netsh advfirewall firewall set rule group='Windows Remote Management' new enable=yes|Out-Null
}catch{Log "WARN: WinRM: $_"}

Sec 'Local Groups'
try{
  if($AppAdminGroupArray){$AppAdminGroupArray|%{AddLocalMember 'Administrators' $_}}else{Log 'No AppAdminGroup values supplied; skipping Administrators membership'}
  if($AppRemoteGroupArray){$AppRemoteGroupArray|%{AddLocalMember 'Remote Desktop Users' $_}}else{Log 'No AppRemoteGroup values supplied; skipping Remote Desktop Users membership'}
}catch{Log "WARN: local groups: $_"}

if($EnableSHIR){
  Sec 'Self-hosted Integration Runtime'
  DefOn
  try{
    $paths=@((Join-Path $PF 'Microsoft Integration Runtime\5.0\Shared\IntegrationRuntime.ConfigurationManager.exe'),(Join-Path $PF 'Microsoft Integration Runtime\4.0\Shared\IntegrationRuntime.ConfigurationManager.exe'),(Join-Path $PF 'Microsoft Integration Runtime\3.0\Shared\IntegrationRuntime.ConfigurationManager.exe'))
    if(-not($paths|?{Test-Path $_})){
      $msi=Join-Path $DlDir 'IntegrationRuntime.msi';GetPkg 'IntegrationRuntime_*.msi' $msi
      RunMsi 'SHIR' $msi|Out-Null
    }
  }catch{Log "WARN: SHIR install: $_"}finally{DefOff}
  try{
    $key=GetKeyVaultSecretMI "kv-ccoe-cc-${sub}" 'adf-ccoe-shir-default-key'
    if([string]::IsNullOrWhiteSpace($key)){throw 'empty SHIR key'}
    $reg=Join-Path $PF 'Microsoft Integration Runtime\5.0\PowerShellScript\RegisterIntegrationRuntime.ps1'
    if(Test-Path $ShirMarker){Log 'SHIR registration marker exists; skipping registration'}
    elseif(Test-Path $reg){$global:LASTEXITCODE=0;& $reg -gatewayKey $key -NodeName $env:COMPUTERNAME;if($LASTEXITCODE){throw "SHIR registration exit $LASTEXITCODE"};Set-Content -Path $ShirMarker -Value "$(Get-Date -Format o) $env:COMPUTERNAME" -Encoding ascii -Force}
    else{throw 'SHIR register script missing'}
  }catch{Log "WARN: SHIR register: $_"}
}

Sec 'Finalize'
Log 'Init Script completed.'
if($RebootWhenDone){
  Log 'RebootWhenDone requested; forcing immediate reboot'
  try{
    $p=Start-Process shutdown.exe -ArgumentList '/r','/t','5','/f','/c','winvm init2.ps1 completed; immediate reboot requested' -Wait -PassThru -WindowStyle Hidden
    if($p.ExitCode -eq 0){Log 'shutdown.exe accepted reboot request: /r /t 0 /f'}else{Log "WARN: shutdown.exe immediate reboot request exit $($p.ExitCode)"}
  }catch{
    Log "WARN: shutdown.exe immediate reboot request failed: $_"
  }
}else{
  Log 'RebootWhenDone not set; scheduling forced reboot in 5 minutes'
  try{
    $p=Start-Process shutdown.exe -ArgumentList '/r','/t','300','/f','/c','winvm init2.ps1 completed; reboot scheduled in 5 minutes' -Wait -PassThru -WindowStyle Hidden
    if($p.ExitCode -eq 0){Log 'shutdown.exe accepted reboot request: /r /t 300 /f'}else{Log "WARN: shutdown.exe delayed reboot request exit $($p.ExitCode)"}
  }catch{
    Log "WARN: shutdown.exe delayed reboot request failed: $_"
  }
}
Log '===================== Init Script Ends v2.0 compact ====================='
