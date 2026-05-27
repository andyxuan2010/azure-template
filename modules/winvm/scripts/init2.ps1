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

Primary actions:
- Initialize RAW data disks, enable ICMP, configure OpenSSH, BGInfo, scheduled.ps1,
  Azure Arc setup cleanup, secure WinRM, local group membership, and optional SHIR.
- Install/support tools: Az modules, PowerShell 7, Azure CLI, AWS CLI, 7-Zip,
  Sysinternals/BGInfo, VS Code, Storage Explorer, Azure Data Studio, Postman,
  MobaXterm, and AzCopy.

Important switches:
- -EnableSHIR: installs/registers Self-hosted Integration Runtime.
- -EnableDefenderPerformanceMode: temporary Defender exclusions during installs.
- -EnableInsecureWinRM: opt-in only; enables Basic auth and unencrypted WinRM.
- -RebootWhenDone: reboots after completion.
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
  [string]$StorageAccount='stccoeiacccnonprod'
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
$SevenZipExe=Join-Path $PF '7-Zip\7z.exe';$CodeExe=Join-Path $PF 'Microsoft VS Code\Code.exe'
$StorageExplorerExe=Join-Path $PF 'Microsoft Azure Storage Explorer\StorageExplorer.exe';$AdsExe=Join-Path $PF 'Azure Data Studio\azuredatastudio.exe'
$PostmanDir=Join-Path $PF 'Postman';$PostmanExe=Join-Path $PostmanDir 'Postman.exe'
$MobaExe=Join-Path $PF86 'Mobatek\MobaXterm\MobaXterm.exe';$AzCopyDir=Join-Path $PF 'AzCopy';$AzCopyExe=Join-Path $AzCopyDir 'azcopy.exe'
$SshAuthKeys=Join-Path $PD 'ssh\administrators_authorized_keys';$BgInfoCfg=Join-Path $WD 'default.bgi';$BgInfoExe=Join-Path $System32 'Bginfo.exe'
$StartupDir=Join-Path $PD 'Microsoft\Windows\Start Menu\Programs\Startup';$PublicDesktop=Join-Path $PUB 'Desktop'
$DefenderAddedPaths=@();$DefenderAddedProcs=@();$DefenderRealtimeWasDisabled=$null;$ShirMarker=Join-Path $TempRoot 'shir.registered';$ValidationScript=Join-Path $TempRoot 'validation.ps1'
$PackagesBase="https://$StorageAccount.blob.core.windows.net/packages/";$ScriptsBase="https://$StorageAccount.blob.core.windows.net/scripts/"
$global:__AzConnected=$false;$AzLoggedIn=$false
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
function GetHttp($url,$dst,[int]$tries=3){
  Mk(Split-Path $dst -Parent);Remove-PathSafe $dst;$old=$global:ProgressPreference;$global:ProgressPreference='SilentlyContinue'
  try{
    for($i=1;$i -le $tries;$i++){
      try{Invoke-WebRequest -Uri $url -OutFile $dst -UseBasicParsing -ErrorAction Stop;if(Test-Path $dst){return $true}}catch{
        Log "WARN: http $i $url : $_"
        try{$wc=New-Object Net.WebClient;$wc.DownloadFile($url,$dst);if(Test-Path $dst){return $true}}catch{Log "WARN: webclient $i $url : $_"}
        Start-Sleep -Seconds (5*$i)
      }
    }
  }finally{$global:ProgressPreference=$old}
  throw "download failed: $url"
}
function GetToken([string]$res='https://storage.azure.com/'){
  (Invoke-RestMethod -Method GET -Uri "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$([uri]::EscapeDataString($res))" -Headers @{Metadata='true'} -ErrorAction Stop).access_token
}
function GetMI($url,$dst,[int]$tries=3){
  Mk(Split-Path $dst -Parent);Remove-PathSafe $dst;$h=@{Authorization="Bearer $(GetToken)";'x-ms-version'='2020-10-02'}
  for($i=1;$i -le $tries;$i++){try{Invoke-WebRequest -Uri $url -OutFile $dst -Headers $h -UseBasicParsing -ErrorAction Stop;if(Test-Path $dst){return $true}}catch{Log "WARN: mi $i $url : $_";Start-Sleep -Seconds (5*$i)}}
  throw "mi download failed: $url"
}
function StorageCtx{if(-not $global:__AzConnected){throw 'Az context unavailable'};New-AzStorageContext -StorageAccountName $StorageAccount -UseConnectedAccount}
function BlobName($container,$pattern){
  $m=Get-AzStorageBlob -Container $container -Context (StorageCtx) -ErrorAction Stop|?{$_.Name -like $pattern}
  if(-not $m){throw "no blob $container/$pattern"}
  ($m|Sort-Object {$_.ICloudBlob.Properties.LastModified.UtcDateTime} -Descending|Select-Object -First 1).Name
}
function GetBlob($container,$name,$dst){
  Mk(Split-Path $dst -Parent);Get-AzStorageBlobContent -Container $container -Context (StorageCtx) -Blob $name -Destination $dst -Force -ErrorAction Stop|Out-Null
}
function GetPkg($pattern,$dst){
  try{$n=BlobName packages $pattern;Log "MI blob packages/$n";GetBlob packages $n $dst}catch{Log "WARN: MI package $pattern : $_; using HTTPS";GetHttp (PkgUrl $pattern) $dst}
}
function GetScript($name,$dst){
  try{GetBlob scripts $name $dst}catch{Log "WARN: MI script $name : $_; using HTTPS";GetHttp (ScriptUrl $name) $dst}
}
function TryGetScript($name,$dst){
  try{GetBlob scripts $name $dst;return (Test-Path $dst)}catch{return $false}
}
function MSI($name,$pattern,$detect){
  Sec "Install: $name";$t=Get-Date
  if($detect -and (Test-Path $detect)){Log "$name already present";return}
  $msi = Join-Path $DlDir (($name -replace '[^A-Za-z0-9]', '') + '.msi')
  GetPkg $pattern $msi
  $p=Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru -WindowStyle Hidden
  if($p.ExitCode -notin 0,3010,1641){throw "$name MSI exit $($p.ExitCode)"}
  if($detect -and -not(Test-Path $detect)){throw "$name install did not create expected path: $detect"}
  Log "$name done $(Dur $t (Get-Date))"
}
function EXE($name,$pattern,$detect,$args){
  Sec "Install: $name";$t=Get-Date
  if($detect -and (Test-Path $detect)){Log "$name already present";return}
  $exe=Join-Path $DlDir (($name -replace '[^A-Za-z0-9]','')+'.exe')
  GetPkg $pattern $exe
  $p=Start-Process -FilePath $exe -ArgumentList $args -Wait -PassThru -WindowStyle Hidden
  if($p.ExitCode -notin 0,3010,1641){Log "WARN: $name installer exit $($p.ExitCode)"}
  if($detect -and -not(Test-Path $detect)){throw "$name install did not create expected path: $detect"}
  Log "$name done $(Dur $t (Get-Date))"
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
  $azZip=Join-Path $DlDir 'az-modules.zip';$azExt=Join-Path $WorkDir 'azmods_extracted';$ps51=Join-Path $PF 'WindowsPowerShell\Modules'
  if(Get-Module -ListAvailable Az.Accounts -ErrorAction SilentlyContinue){Log 'Az modules already present; skipping module copy'}else{
    try{GetMI (PkgUrl 'az-modules.zip') $azZip}catch{Log "WARN: az-modules MI failed: $_";GetHttp (PkgUrl 'az-modules.zip') $azZip}
    Remove-PathSafe $azExt;Expand-Archive -Path $azZip -DestinationPath $azExt -Force;Mk $ps51
    Get-ChildItem $azExt -Directory|%{CopyDir $_.FullName (Join-Path $ps51 $_.Name)}
    Remove-PathSafe $azZip
  }
  try{Import-Module Az.Accounts -ErrorAction Stop}catch{Log "WARN: import Az.Accounts: $_"}

  Sec 'Azure Managed Identity Login'
  try{if(-not(Get-AzContext -ErrorAction SilentlyContinue)){Connect-AzAccount -Identity -ErrorAction Stop|Out-Null};$global:__AzConnected=$true;$AzLoggedIn=$true;Log 'Az MI login ok'}catch{Log "WARN: Az MI login: $_"}

  MSI 'PowerShell7' 'PowerShell-*-win-x64.msi' $PwshExe
  Sec 'Az Modules PS 7 Copy'
  $ps7=Join-Path $PwshDir 'Modules'
  if(Test-Path $ps7){
    $src=Get-ChildItem $azExt -Directory -ErrorAction SilentlyContinue
    if(-not $src -and -not(Test-Path (Join-Path $ps7 'Az.Accounts'))){$src=Get-ChildItem $ps51 -Directory -Filter 'Az*' -ErrorAction SilentlyContinue}
    if($src){$src|%{CopyDir $_.FullName (Join-Path $ps7 $_.Name)}}else{Log 'Az extraction folder absent; PS7 copy already satisfied or skipped'}
  }else{Log 'WARN: PS7 modules path missing'}

  MSI 'AzureCLI' 'azure-cli-*.msi' $AzCliExe
  MSI 'AWSCLI' 'AWSCLIV2*.msi' $AwsExe
  MSI '7Zip' '7z*-x64.msi' $SevenZipExe

  Sec 'Sysinternals'
  if(Test-Path $BgInfoExe){Log 'Sysinternals/BGInfo already present; skipping extract'}else{$sysZip=Join-Path $DlDir 'SysinternalsSuite.zip';GetPkg 'SysinternalsSuite*.zip' $sysZip;Expand-Archive -Path $sysZip -DestinationPath $System32 -Force}

  EXE 'VSCode' 'VSCodeSetup-x64-*.exe' $CodeExe '/verysilent /suppressmsgboxes /mergetasks=!runcode'
  EXE 'StorageExplorer' 'StorageExplorer-windows-x64*.exe' $StorageExplorerExe '/ALLUSERS /VERYSILENT /SP- /SUPPRESSMSGBOXES /NORESTART'
  EXE 'AzureDataStudio' 'azuredatastudio-windows-setup-*.exe' $AdsExe '/sp- /verysilent /suppressmsgboxes /norestart /MERGETASKS=!runcode'

  Sec 'Postman'
  $pmPf=$PostmanExe;$pmLocal=FindPostmanInstall
  if(-not(Test-Path $pmPf)){
    Get-Process -Name Postman,PostmanAgent -ErrorAction SilentlyContinue|Stop-Process -Force -ErrorAction SilentlyContinue
    $pm=Join-Path $DlDir 'Postman.exe';GetPkg 'Postman-win64-Setup*.exe' $pm
    $p=Start-Process -FilePath $pm -ArgumentList '--silent' -PassThru -WindowStyle Hidden
    $end=(Get-Date).AddMinutes(8);while((Get-Date)-lt $end -and -not $p.HasExited -and -not(FindPostmanInstall)){Start-Sleep 5}
    if(-not $p.HasExited){Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue}
    $pmLocal=FindPostmanInstall
    if(-not $pmLocal){
      Log 'WARN: Postman --silent did not produce an install tree; trying /S'
      $p=Start-Process -FilePath $pm -ArgumentList '/S' -PassThru -WindowStyle Hidden
      $end=(Get-Date).AddMinutes(5);while((Get-Date)-lt $end -and -not $p.HasExited -and -not(FindPostmanInstall)){Start-Sleep 5}
      if(-not $p.HasExited){Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue}
      $pmLocal=FindPostmanInstall
    }
    if($pmLocal -and (Test-Path $pmLocal) -and -not(Test-Path $pmPf)){Mk $PostmanDir;CopyDir $pmLocal $PostmanDir}
  }
  if(Test-Path $pmPf){try{Mk $PublicDesktop;$sh=New-Object -ComObject WScript.Shell;$sc=$sh.CreateShortcut((Join-Path $PublicDesktop 'Postman.lnk'));$sc.TargetPath=$pmPf;$sc.Save()}catch{Log "WARN: Postman shortcut: $_"}}else{Log "WARN: Postman not verified at $pmPf; no shortcut created"}

  Sec 'MobaXterm'
  if(-not(Test-Path $MobaExe)){
    $mz=Join-Path $DlDir 'MobaXterm.zip';$mw=Join-Path $WorkDir 'MobaXterm';Remove-PathSafe $mw;GetPkg 'MobaXterm_Installer_v*.zip' $mz;Expand-Archive -Path $mz -DestinationPath $mw -Force
    $m=Get-ChildItem $mw -Filter *.msi -Recurse|Select-Object -First 1
    if($m){$p=Start-Process msiexec.exe -ArgumentList "/i `"$($m.FullName)`" /qn /norestart" -Wait -PassThru -WindowStyle Hidden;if($p.ExitCode -notin 0,3010,1641){throw "MobaXterm MSI exit $($p.ExitCode)"}}else{Log 'WARN: MobaXterm MSI not found'}
  }

  Sec 'AzCopy'
  $azcopyExe=$AzCopyExe;$azcopyDest=$AzCopyDir
  if(-not(Test-Path $azcopyExe)){
    $azcopyZip=Join-Path $DlDir 'azcopy.zip';Remove-PathSafe $azcopyDest;GetPkg 'azcopy_windows_amd64_*.zip' $azcopyZip;Expand-Archive -Path $azcopyZip -DestinationPath $azcopyDest -Force
    $f=Get-ChildItem $azcopyDest -Recurse -Filter azcopy.exe|Select-Object -First 1
    if($f -and $f.FullName -ne $azcopyExe){Move-Item $f.FullName $azcopyExe -Force}
  }
}catch{Log "ERROR: software install failed: $_";Exit 1}finally{DefOff}

Sec 'PATH Updates'
try{
  AddPath @($AwsDir,$AzCliDir,$PwshDir,$AzCopyDir)
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
  if(-not(Test-Path $BgInfoExe)){throw "BGInfo executable not found at $BgInfoExe; confirm SysinternalsSuite*.zip contains Bginfo.exe"}
  $cfg=$BgInfoCfg;GetScript 'default.bgi' $cfg
  Mk $StartupDir
  $lnk=Join-Path $StartupDir 'BGInfo.lnk';$sh=New-Object -ComObject WScript.Shell;$sc=$sh.CreateShortcut($lnk)
  $sc.TargetPath=$BgInfoExe;$sc.Arguments="`"$cfg`" /timer:0 /silent /nolicprompt";$sc.Save()
}catch{Log "ERROR: BGInfo: $_";Exit 1}

Sec 'Scheduled Task'
try{
  $sched=Join-Path $WorkDir 'scheduled.ps1';GetScript 'scheduled.ps1' $sched;Unblock-File $sched -ErrorAction SilentlyContinue
  $act=New-ScheduledTaskAction -Execute powershell.exe -Argument "-NoProfile -WindowStyle Minimized -ExecutionPolicy Bypass -File `"$sched`""
  $trg=New-ScheduledTaskTrigger -AtLogOn
  try{$prn=New-ScheduledTaskPrincipal -UserId azureadmin -LogonType Interactive -RunLevel Highest}catch{$prn=New-ScheduledTaskPrincipal -UserId INTERACTIVE -LogonType Interactive}
  Register-ScheduledTask -TaskName RunAppxInstall -Action $act -Trigger $trg -Principal $prn -Force|Out-Null
}catch{Log "ERROR: scheduled task: $_";Exit 1}

Sec 'Validation Tool'
if(TryGetScript 'validation.ps1' $ValidationScript){
  Unblock-File $ValidationScript -ErrorAction SilentlyContinue
  Log "Validation script available at $ValidationScript"
}else{Log 'Validation script not found in scripts container; continuing without VM-side validation tool'}

Sec 'Azure Arc Cleanup'
try{
  $sm='HKLM:\SOFTWARE\Microsoft\ServerManager';$pol='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System'
  if(-not(Test-Path $sm)){New-Item -Path $sm -Force|Out-Null};Set-ItemProperty -Path $sm -Name DoNotPopulateAzureArcTiles -Type DWord -Value 1 -ErrorAction SilentlyContinue
  if(-not(Test-Path $pol)){New-Item -Path $pol -Force|Out-Null};Set-ItemProperty -Path $pol -Name DisableAzureArcSetup -Type DWord -Value 1 -ErrorAction SilentlyContinue
  Remove-PathSafe (Join-Path $PD 'Microsoft\Windows\Start Menu\Programs\Azure Arc Setup.lnk')
  $cap=Get-WindowsCapability -Online -Name 'AzureArcSetup~~~~' -ErrorAction SilentlyContinue
  if($cap -and $cap.State -eq 'Installed'){
    $p=Start-Process dism.exe -ArgumentList '/online /Remove-Capability /CapabilityName:AzureArcSetup~~~~ /NoRestart' -Wait -PassThru -WindowStyle Hidden
    if($p.ExitCode -notin 0,3010){Log "WARN: AzureArcSetup removal exit $($p.ExitCode)"}else{Log 'AzureArcSetup capability removed or pending restart'}
  }else{Log 'AzureArcSetup capability not installed'}
}catch{Log "WARN: Arc cleanup: $_"}

Sec 'WinRM'
try{
  Enable-PSRemoting -Force -SkipNetworkProfileCheck|Out-Null
  winrm set winrm/config/service '@{AllowUnencrypted=false}'|Out-Null
  winrm set winrm/config/service/auth '@{Basic=false}'|Out-Null
  if($EnableInsecureWinRM){
    Log 'WARN: EnableInsecureWinRM set; enabling Basic auth and unencrypted WinRM'
    winrm set winrm/config/service '@{AllowUnencrypted=true}'|Out-Null
    winrm set winrm/config/service/auth '@{Basic=true}'|Out-Null
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
      $p=Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru -WindowStyle Hidden
      if($p.ExitCode -notin 0,3010,1641){throw "SHIR MSI exit $($p.ExitCode)"}
    }
  }catch{Log "WARN: SHIR install: $_"}finally{DefOff}
  try{
    if(-not $AzLoggedIn){Connect-AzAccount -Identity -ErrorAction Stop|Out-Null}
    $key=Get-AzKeyVaultSecret -VaultName "kv-ccoe-cc-${sub}" -Name 'adf-ccoe-shir-default-key' -AsPlainText -ErrorAction Stop
    if([string]::IsNullOrWhiteSpace($key)){throw 'empty SHIR key'}
    $reg=Join-Path $PF 'Microsoft Integration Runtime\5.0\PowerShellScript\RegisterIntegrationRuntime.ps1'
    if(Test-Path $ShirMarker){Log 'SHIR registration marker exists; skipping registration'}
    elseif(Test-Path $reg){$global:LASTEXITCODE=0;& $reg -gatewayKey $key -NodeName $env:COMPUTERNAME;if($LASTEXITCODE){throw "SHIR registration exit $LASTEXITCODE"};Set-Content -Path $ShirMarker -Value "$(Get-Date -Format o) $env:COMPUTERNAME" -Encoding ascii -Force}
    else{throw 'SHIR register script missing'}
  }catch{Log "WARN: SHIR register: $_"}
}

Sec 'Finalize'
if($AzLoggedIn){try{Get-AzContext -ErrorAction Stop|Out-Null;Log 'Az context ok'}catch{Log "WARN: Az context check: $_"}}
Log 'Init Script completed.'
if($RebootWhenDone){Log 'Rebooting now';shutdown -r -t 0 -f}else{Log 'Reboot skipped'}
Log '===================== Init Script Ends v2.0 compact ====================='
