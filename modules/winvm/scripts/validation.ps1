param(
  [string]$ReportPath='',
  [switch]$ExpectSHIR=$false,
  [switch]$ExpectReboot=$false,
  [switch]$ExpectInsecureWinRM=$false,
  [string]$AppUserGroup='',
  [string]$AppRemoteGroup='',
  [string]$AppAdminGroup=''
)

$SD=$env:SystemDrive;if(-not $SD){$SD='C:'}
$PF=$env:ProgramFiles;if(-not $PF){$PF=Join-Path $SD 'Program Files'}
$PF86=${env:ProgramFiles(x86)};if(-not $PF86){$PF86=Join-Path $SD 'Program Files (x86)'}
$PD=$env:ProgramData;if(-not $PD){$PD=Join-Path $SD 'ProgramData'}
$WD=$env:WINDIR;if(-not $WD){$WD=Join-Path $SD 'Windows'}
$PUB=$env:PUBLIC;if(-not $PUB){$PUB=Join-Path $SD 'Users\Public'}
$System32=Join-Path $WD 'System32'
$TempRoot=Join-Path $PD 'Bootstrap'
$LogFile=Join-Path $PD 'Logs\Init\InitLog.txt'
if(-not $ReportPath){$ReportPath=Join-Path $PD 'Logs\Init\ValidationReport.txt'}
$ReportDir=Split-Path $ReportPath -Parent
if(-not(Test-Path $ReportDir)){New-Item -ItemType Directory -Path $ReportDir -Force|Out-Null}
$PostCloudInitTask=Get-ScheduledTask -TaskName 'post-cloud-init' -ErrorAction SilentlyContinue

$Results=New-Object System.Collections.Generic.List[object]
function Add-Result($Name,$Status,$Details=''){
  $Results.Add([pscustomobject]@{Name=$Name;Status=$Status;Details=$Details})|Out-Null
}
function Test-File($Name,$Path){
  if(Test-Path $Path){Add-Result $Name 'PASS' $Path}else{Add-Result $Name 'FAIL' "Missing: $Path"}
}
function Test-ScheduledFile($Name,$Path){
  if(Test-Path $Path){Add-Result $Name 'PASS' $Path;return}
  if($PostCloudInitTask -and $PostCloudInitTask.State -ne 'Disabled'){
    Add-Result $Name 'SKIP' "Pending scheduled.ps1 completion: $Path"
  }else{
    Add-Result $Name 'FAIL' "Missing after scheduled.ps1 should have completed: $Path"
  }
}
function Test-CommandPresent($Name,$Command){
  $c=Get-Command $Command -ErrorAction SilentlyContinue
  if($c){Add-Result $Name 'PASS' $c.Source}else{Add-Result $Name 'FAIL' "Command not found: $Command"}
}
function Test-ServiceState($Name,$ServiceName,$RequiredStatus='Running'){
  $s=Get-Service $ServiceName -ErrorAction SilentlyContinue
  if(-not $s){Add-Result $Name 'FAIL' "Service missing: $ServiceName";return}
  if($s.Status -eq $RequiredStatus){Add-Result $Name 'PASS' "$ServiceName is $($s.Status)"}else{Add-Result $Name 'FAIL' "$ServiceName is $($s.Status), expected $RequiredStatus"}
}
function Test-RegistryValue($Name,$Path,$ValueName,$Expected){
  try{
    $v=(Get-ItemProperty -Path $Path -Name $ValueName -ErrorAction Stop).$ValueName
    if($v -eq $Expected){Add-Result $Name 'PASS' "$Path\$ValueName=$v"}else{Add-Result $Name 'FAIL' "$Path\$ValueName=$v, expected $Expected"}
  }catch{Add-Result $Name 'FAIL' "Missing or unreadable: $Path\$ValueName"}
}
function Test-PathEntry($Name,$Path){
  $cur=[Environment]::GetEnvironmentVariable('Path','Machine')
  $want=$Path.TrimEnd('\').ToLowerInvariant()
  $hit=@($cur -split ';'|?{$_.TrimEnd('\').ToLowerInvariant() -eq $want})
  if($hit.Count -gt 0){Add-Result $Name 'PASS' $Path}else{Add-Result $Name 'FAIL' "PATH missing: $Path"}
}
function Test-ScheduledPathEntry($Name,$Path){
  $cur=[Environment]::GetEnvironmentVariable('Path','Machine')
  $want=$Path.TrimEnd('\').ToLowerInvariant()
  $hit=@($cur -split ';'|?{$_.TrimEnd('\').ToLowerInvariant() -eq $want})
  if($hit.Count -gt 0){Add-Result $Name 'PASS' $Path;return}
  if($PostCloudInitTask -and $PostCloudInitTask.State -ne 'Disabled'){
    Add-Result $Name 'SKIP' "Pending scheduled.ps1 completion: $Path"
  }else{
    Add-Result $Name 'FAIL' "PATH missing after scheduled.ps1 should have completed: $Path"
  }
}
function Test-LocalMember($LocalGroup,$Member){
  if([string]::IsNullOrWhiteSpace($Member)){return}
  if($Member -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'){
    Add-Result "Local group $LocalGroup includes $Member" 'SKIP' 'GUID/object ID is not a Windows account name or SID'
    return
  }
  try{
    $hit=Get-LocalGroupMember -Group $LocalGroup -ErrorAction Stop|?{$_.Name -ieq $Member -or $_.SID.Value -ieq $Member}
    if($hit){Add-Result "Local group $LocalGroup includes $Member" 'PASS' $Member}else{Add-Result "Local group $LocalGroup includes $Member" 'FAIL' 'Member not found'}
  }catch{Add-Result "Local group $LocalGroup includes $Member" 'FAIL' "$_"}
}

Write-Host "Validating init2.ps1 outcomes..."
$RemoteDesktopGroupInput=(@($AppUserGroup,$AppRemoteGroup) -join ',')

Test-File 'Init log created' $LogFile
Test-File 'Bootstrap workspace created' $TempRoot

try{
  $tz=Get-TimeZone -ErrorAction Stop
  if($tz.Id -eq 'Eastern Standard Time'){Add-Result 'Windows time zone' 'PASS' $tz.Id}else{Add-Result 'Windows time zone' 'FAIL' "Expected Eastern Standard Time, got $($tz.Id)"}
}catch{Add-Result 'Windows time zone' 'FAIL' "$_"}

$icmp=Get-NetFirewallRule -DisplayName 'Allow ICMPv4-In' -ErrorAction SilentlyContinue
if($icmp -and $icmp.Enabled -eq 'True'){Add-Result 'ICMP firewall rule' 'PASS' 'Allow ICMPv4-In enabled'}else{Add-Result 'ICMP firewall rule' 'FAIL' 'Allow ICMPv4-In missing or disabled'}

$raw=Get-Disk -ErrorAction SilentlyContinue|?{$_.PartitionStyle -eq 'RAW' -and -not $_.IsBoot -and -not $_.IsSystem}
if($raw){Add-Result 'RAW data disks initialized' 'FAIL' "RAW disks remain: $($raw.Number -join ',')"}else{Add-Result 'RAW data disks initialized' 'PASS' 'No non-boot RAW disks found'}

$azAcct=Get-Module -ListAvailable Az.Accounts -ErrorAction SilentlyContinue|Select-Object -First 1
if($azAcct){Add-Result 'Az.Accounts module' 'PASS' $azAcct.ModuleBase}elseif($PostCloudInitTask -and $PostCloudInitTask.State -ne 'Disabled'){Add-Result 'Az.Accounts module' 'SKIP' 'Pending scheduled.ps1 completion'}else{Add-Result 'Az.Accounts module' 'FAIL' 'Missing after scheduled.ps1 should have completed'}
$azAcctPs7=Join-Path $PF 'PowerShell\7\Modules\Az.Accounts'
if(Test-Path $azAcctPs7){Add-Result 'Az.Accounts module PS7 copy' 'PASS' $azAcctPs7}elseif($PostCloudInitTask -and $PostCloudInitTask.State -ne 'Disabled'){Add-Result 'Az.Accounts module PS7 copy' 'SKIP' 'Pending scheduled.ps1 completion'}else{Add-Result 'Az.Accounts module PS7 copy' 'FAIL' 'Missing after scheduled.ps1 should have completed'}

Test-File 'PowerShell 7' (Join-Path $PF 'PowerShell\7\pwsh.exe')
Test-File 'Azure CLI' (Join-Path $PF86 'Microsoft SDKs\Azure\CLI2\wbin\az.cmd')
Test-File '7-Zip' (Join-Path $PF '7-Zip\7z.exe')
Test-ScheduledFile 'AWS CLI' (Join-Path $PF 'Amazon\AWSCLIV2\aws.exe')
Test-ScheduledFile 'Git' (Join-Path $PF 'Git\cmd\git.exe')
Test-ScheduledFile 'Terraform' (Join-Path $System32 'terraform.exe')
Test-ScheduledFile 'Sysinternals PsExec' (Join-Path $System32 'PsExec.exe')
Test-ScheduledFile 'Postman' (Join-Path $PF 'Postman\Postman.exe')
Test-ScheduledFile 'MobaXterm' (Join-Path $PF86 'Mobatek\MobaXterm\MobaXterm.exe')
Test-ScheduledFile 'AzCopy' (Join-Path $PF 'AzCopy\azcopy.exe')
Test-File 'BGInfo executable' (Join-Path $System32 'Bginfo.exe')
Test-File 'BGInfo config' (Join-Path $WD 'default.bgi')
Test-File 'Background wallpaper' (Join-Path $WD 'Web\Wallpaper\Background\background.png')
Test-File 'BGInfo launcher' (Join-Path $TempRoot 'Run-BGInfo.ps1')
Test-File 'Wallpaper apply helper' (Join-Path $TempRoot 'Set-BackgroundWallpaper.ps1')
Test-File 'BGInfo user log' (Join-Path $TempRoot 'BGInfoUser.log')

Test-PathEntry 'PATH Azure CLI' (Join-Path $PF86 'Microsoft SDKs\Azure\CLI2\wbin')
Test-PathEntry 'PATH PowerShell 7' (Join-Path $PF 'PowerShell\7')
Test-ScheduledPathEntry 'PATH AWS CLI' (Join-Path $PF 'Amazon\AWSCLIV2')
Test-ScheduledPathEntry 'PATH AzCopy' (Join-Path $PF 'AzCopy')
Test-ScheduledPathEntry 'PATH Git' (Join-Path $PF 'Git\cmd')
Test-ScheduledPathEntry 'PATH Terraform' $System32

Test-ServiceState 'OpenSSH service' 'sshd' 'Running'
$sshRule=Get-NetFirewallRule -DisplayName 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue
if($sshRule -and $sshRule.Enabled -eq 'True'){Add-Result 'OpenSSH firewall rule' 'PASS' 'OpenSSH-Server-In-TCP enabled'}else{Add-Result 'OpenSSH firewall rule' 'FAIL' 'OpenSSH firewall rule missing or disabled'}
Test-File 'OpenSSH authorized_keys' (Join-Path $PD 'ssh\administrators_authorized_keys')

if(Test-Path (Join-Path $PUB 'Desktop\Postman.lnk')){Add-Result 'Postman public shortcut expected state' 'PASS' (Join-Path $PUB 'Desktop\Postman.lnk')}elseif($PostCloudInitTask -and $PostCloudInitTask.State -ne 'Disabled'){Add-Result 'Postman public shortcut expected state' 'SKIP' 'Pending scheduled.ps1 completion'}else{Add-Result 'Postman public shortcut expected state' 'FAIL' 'Missing after scheduled.ps1 should have completed'}
Test-File 'BGInfo startup shortcut' (Join-Path $PD 'Microsoft\Windows\Start Menu\Programs\Startup\BGInfo.lnk')
if(Test-Path (Join-Path $SD 'Users\azureadmin')){
  Test-File 'BGInfo azureadmin startup shortcut' (Join-Path $SD 'Users\azureadmin\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\BGInfo.lnk')
}else{
  Add-Result 'BGInfo azureadmin startup shortcut' 'SKIP' 'azureadmin profile folder not present'
}
$bgTask=Get-ScheduledTask -TaskName 'RunBGInfoAtLogon' -ErrorAction SilentlyContinue
if($bgTask){Add-Result 'Scheduled task RunBGInfoAtLogon' 'PASS' "$($bgTask.State)"}else{Add-Result 'Scheduled task RunBGInfoAtLogon' 'FAIL' 'Task missing'}

try{
  $wallpaper=Join-Path $WD 'Web\Wallpaper\Background\background.png'
  $defaultDesktop='Registry::HKEY_USERS\.DEFAULT\Control Panel\Desktop'
  $defaultWallpaper=(Get-ItemProperty -Path $defaultDesktop -Name Wallpaper -ErrorAction SilentlyContinue).Wallpaper
  if($defaultWallpaper -eq $wallpaper){Add-Result 'Default user wallpaper registry' 'PASS' $defaultWallpaper}else{Add-Result 'Default user wallpaper registry' 'WARN' "Expected $wallpaper, got $defaultWallpaper"}
}catch{Add-Result 'Default user wallpaper registry' 'WARN' "$_"}

try{
  $desktop=Get-ItemProperty 'HKCU:\Control Panel\Desktop' Wallpaper,WallpaperStyle,TileWallpaper -ErrorAction Stop
  if($desktop.Wallpaper -match 'BGInfo\.bmp$' -or $desktop.Wallpaper -eq (Join-Path $WD 'Web\Wallpaper\Background\background.png')){
    Add-Result 'Current user wallpaper path' 'PASS' "$($desktop.Wallpaper)"
  }else{
    Add-Result 'Current user wallpaper path' 'WARN' "$($desktop.Wallpaper)"
  }
  if($desktop.WallpaperStyle -eq '10' -and $desktop.TileWallpaper -eq '0'){Add-Result 'Current user wallpaper style' 'PASS' "WallpaperStyle=10 TileWallpaper=0"}else{Add-Result 'Current user wallpaper style' 'WARN' "WallpaperStyle=$($desktop.WallpaperStyle) TileWallpaper=$($desktop.TileWallpaper)"}
}catch{Add-Result 'Current user wallpaper state' 'WARN' "$_"}

if($PostCloudInitTask){
  Add-Result 'Scheduled task post-cloud-init' 'PASS' "$($PostCloudInitTask.State)"
  $taskActions=@($PostCloudInitTask.Actions|%{"$($_.Execute) $($_.Arguments)"})
  $taskTriggers=@($PostCloudInitTask.Triggers|%{$_.CimClass.CimClassName})
  if($PostCloudInitTask.Principal.UserId -in @('SYSTEM','S-1-5-18')){
    Add-Result 'post-cloud-init principal' 'PASS' "$($PostCloudInitTask.Principal.UserId) $($PostCloudInitTask.Principal.LogonType)"
  }else{
    Add-Result 'post-cloud-init principal' 'FAIL' "$($PostCloudInitTask.Principal.UserId) $($PostCloudInitTask.Principal.LogonType)"
  }
  if($taskTriggers -contains 'MSFT_TaskBootTrigger'){
    Add-Result 'post-cloud-init boot trigger' 'PASS' ($taskTriggers -join ',')
  }else{
    Add-Result 'post-cloud-init boot trigger' 'FAIL' ($taskTriggers -join ',')
  }
  if($taskTriggers -contains 'MSFT_TaskIdleTrigger'){
    Add-Result 'post-cloud-init idle trigger' 'PASS' ($taskTriggers -join ',')
  }else{
    Add-Result 'post-cloud-init idle trigger' 'WARN' ($taskTriggers -join ',')
  }
  if($PostCloudInitTask.Settings.RunOnlyIfIdle){
    Add-Result 'post-cloud-init RunOnlyIfIdle' 'PASS' "IdleDuration=$($PostCloudInitTask.Settings.IdleSettings.IdleDuration) WaitTimeout=$($PostCloudInitTask.Settings.IdleSettings.WaitTimeout)"
  }else{
    Add-Result 'post-cloud-init RunOnlyIfIdle' 'FAIL' 'RunOnlyIfIdle is false'
  }
  if(($taskActions -join ' ') -match 'scheduled\.ps1'){
    Add-Result 'post-cloud-init action' 'PASS' ($taskActions -join ' | ')
  }else{
    Add-Result 'post-cloud-init action' 'FAIL' ($taskActions -join ' | ')
  }
}else{Add-Result 'Scheduled task post-cloud-init' 'FAIL' 'Task missing'}
$sched=Join-Path $TempRoot 'work\scheduled.ps1'
Test-File 'scheduled.ps1 downloaded' $sched
if(Test-Path (Join-Path $TempRoot 'work\localization')){Add-Result 'Localization work directory' 'PASS' (Join-Path $TempRoot 'work\localization')}else{Add-Result 'Localization work directory' 'WARN' 'Localization directory not found; localization may not have run yet'}

Test-RegistryValue 'Azure Arc Server Manager tile disabled' 'HKLM:\SOFTWARE\Microsoft\ServerManager' 'DoNotPopulateAzureArcTiles' 1
Test-RegistryValue 'Azure Arc setup disabled policy' 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' 'DisableAzureArcSetup' 1
$arcShortcut=Join-Path $PD 'Microsoft\Windows\Start Menu\Programs\Azure Arc Setup.lnk'
if(Test-Path $arcShortcut){Add-Result 'Azure Arc shortcut removed' 'FAIL' "Still exists: $arcShortcut"}else{Add-Result 'Azure Arc shortcut removed' 'PASS' 'Shortcut absent'}
$arcCap=Get-WindowsCapability -Online -Name 'AzureArcSetup~~~~' -ErrorAction SilentlyContinue
if($arcCap -and $arcCap.State -eq 'Installed'){Add-Result 'AzureArcSetup capability removed' 'FAIL' 'Capability still installed'}else{Add-Result 'AzureArcSetup capability removed' 'PASS' "State: $($arcCap.State)"}

try{
  $svc=winrm get winrm/config/service 2>$null
  $auth=winrm get winrm/config/service/auth 2>$null
  $allowUnencrypted=if($ExpectInsecureWinRM){'true'}else{'false'}
  $basic=if($ExpectInsecureWinRM){'true'}else{'false'}
  $svcOk=($svc -match "AllowUnencrypted = $allowUnencrypted")
  $authOk=($auth -match "Basic = $basic")
  if($svcOk -and $authOk){Add-Result 'WinRM settings' 'PASS' "AllowUnencrypted=$allowUnencrypted Basic=$basic"}else{Add-Result 'WinRM settings' 'FAIL' "Expected AllowUnencrypted=$allowUnencrypted Basic=$basic"}
}catch{Add-Result 'WinRM settings' 'FAIL' "$_"}

if($AppAdminGroup){
  $AppAdminGroup -split ','|%{$_.Trim()}|?{$_}|%{Test-LocalMember 'Administrators' $_}
}else{
  Add-Result 'Administrators membership validation' 'SKIP' 'Pass -AppAdminGroup to validate local admin group membership'
}
if($RemoteDesktopGroupInput -and ($RemoteDesktopGroupInput -split ','|%{$_.Trim()}|?{$_})){
  $RemoteDesktopGroupInput -split ','|%{$_.Trim()}|?{$_}|Select-Object -Unique|%{Test-LocalMember 'Remote Desktop Users' $_}
}else{
  Add-Result 'Remote Desktop Users membership validation' 'SKIP' 'Pass -AppUserGroup to validate RDP group membership'
}

if($ExpectSHIR){
  $shirPaths=@(
    (Join-Path $PF 'Microsoft Integration Runtime\5.0\Shared\IntegrationRuntime.ConfigurationManager.exe'),
    (Join-Path $PF 'Microsoft Integration Runtime\4.0\Shared\IntegrationRuntime.ConfigurationManager.exe'),
    (Join-Path $PF 'Microsoft Integration Runtime\3.0\Shared\IntegrationRuntime.ConfigurationManager.exe')
  )
  $found=$shirPaths|?{Test-Path $_}|Select-Object -First 1
  if($found){Add-Result 'SHIR installed' 'PASS' $found}else{Add-Result 'SHIR installed' 'FAIL' 'Integration Runtime executable not found'}
  Test-File 'SHIR registration marker' (Join-Path $TempRoot 'shir.registered')
}else{
  Add-Result 'SHIR validation' 'SKIP' 'Use -ExpectSHIR to require SHIR validation'
}

if($ExpectReboot){
  $pending=@()
  if(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending'){$pending+='CBS'}
  if(Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'){$pending+='WindowsUpdate'}
  if($pending){Add-Result 'Reboot pending' 'PASS' ($pending -join ',')}else{Add-Result 'Reboot pending' 'WARN' 'No common pending reboot markers found'}
}else{
  Add-Result 'Reboot validation' 'SKIP' 'Use -ExpectReboot if reboot was requested'
}

$pass=($Results|?{$_.Status -eq 'PASS'}).Count
$fail=($Results|?{$_.Status -eq 'FAIL'}).Count
$warn=($Results|?{$_.Status -eq 'WARN'}).Count
$skip=($Results|?{$_.Status -eq 'SKIP'}).Count
$overall=if($fail -eq 0){'PASS'}else{'FAIL'}

$lines=@()
$lines+="Init2 Validation Summary"
$lines+="Generated: $(Get-Date -Format o)"
$lines+="Computer: $env:COMPUTERNAME"
$lines+="Overall: $overall"
$lines+="PASS=$pass FAIL=$fail WARN=$warn SKIP=$skip"
$lines+=''
$lines+=($Results|Sort-Object Status,Name|Format-Table -AutoSize|Out-String).TrimEnd()
$lines|Set-Content -Path $ReportPath -Encoding utf8
$lines|%{Write-Host $_}

if($fail -gt 0){exit 1}
exit 0
