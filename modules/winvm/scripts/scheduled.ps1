<#
Post-logon bootstrap continuation for the winvm module.

Run context:
- Registered by init2.ps1 as the post-cloud-init scheduled task.
- Runs as SYSTEM 5 minutes after VM boot when no users are logged on.
- Intended for larger installs that init2.ps1 intentionally skips.

Key locations align with init2.ps1:
- Main log:   $env:ProgramData\Logs\Init\InitLog.txt unless -LogFile is set.
- Workspace:  $env:ProgramData\Bootstrap
- Downloads:  $env:ProgramData\Bootstrap\dl
- Work files: $env:ProgramData\Bootstrap\work
#>

param(
  [string]$StorageAccount='stccoeiacccnonprod',
  [string]$PackageContainer='packages',
  [string]$LocalizationContainer='localization',
  [string]$VMName='',
  [string]$LogFile='',
  [switch]$EnableDefenderPerformanceMode=$false
)

try{[Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12 -bor 3072}catch{}
$SD=$env:SystemDrive;if(-not $SD){$SD='C:'}
$PF=$env:ProgramFiles;if(-not $PF){$PF=Join-Path $SD 'Program Files'}
$PF86=${env:ProgramFiles(x86)};if(-not $PF86){$PF86=Join-Path $SD 'Program Files (x86)'}
$PD=$env:ProgramData;if(-not $PD){$PD=Join-Path $SD 'ProgramData'}
$WD=$env:WINDIR;if(-not $WD){$WD=Join-Path $SD 'Windows'}
$PUB=$env:PUBLIC;if(-not $PUB){$PUB=Join-Path $SD 'Users\Public'}
$TempRoot=Join-Path $PD 'Bootstrap';if(-not $LogFile){$LogFile=Join-Path $PD 'Logs\Init\InitLog.txt'}
$DlDir=Join-Path $TempRoot 'dl';$WorkDir=Join-Path $TempRoot 'work';$LogsDir=Split-Path $LogFile -Parent;$LocalizationDir=Join-Path $WorkDir 'localization'
$WinTemp=Join-Path $WD 'Temp';$System32=Join-Path $WD 'System32'
$PwshExe=Join-Path $PF 'PowerShell\7\pwsh.exe';$PwshDir=Split-Path $PwshExe -Parent
$AzCliDir=Join-Path $PF86 'Microsoft SDKs\Azure\CLI2\wbin'
$AwsDir=Join-Path $PF 'Amazon\AWSCLIV2';$AwsExe=Join-Path $AwsDir 'aws.exe'
$GitCmdDir=Join-Path $PF 'Git\cmd';$GitExe=Join-Path $GitCmdDir 'git.exe'
$TerraformDir=$System32;$TerraformExe=Join-Path $TerraformDir 'terraform.exe'
$PostmanDir=Join-Path $PF 'Postman';$PostmanExe=Join-Path $PostmanDir 'Postman.exe'
$MobaExe=Join-Path $PF86 'Mobatek\MobaXterm\MobaXterm.exe'
$AzCopyDir=Join-Path $PF 'AzCopy';$AzCopyExe=Join-Path $AzCopyDir 'azcopy.exe'
$SysinternalsDetect=Join-Path $System32 'PsExec.exe'
$PackageContainer=if([string]::IsNullOrWhiteSpace($PackageContainer)){'packages'}else{$PackageContainer.Trim()}
$LocalizationContainer=if([string]::IsNullOrWhiteSpace($LocalizationContainer)){'localization'}else{$LocalizationContainer.Trim()}
if([string]::IsNullOrWhiteSpace($VMName)){$VMName=$env:COMPUTERNAME}
$DefenderAddedPaths=@();$DefenderAddedProcs=@();$DefenderRealtimeWasDisabled=$null

function Mk($p){if($p -and -not(Test-Path -LiteralPath $p)){New-Item -ItemType Directory -Path $p -Force|Out-Null}}
@($TempRoot,$DlDir,$WorkDir,$LogsDir)|%{Mk $_};$env:TEMP=$TempRoot;$env:TMP=$TempRoot
function Log($m){Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $m"}
function Sec($m){Log '----------------------------------------------------------------';Log $m;Log '----------------------------------------------------------------'}
function Dur($a,$b){$t=New-TimeSpan -Start $a -End $b;"{0:00}h:{1:00}m:{2:00}s" -f [int]$t.TotalHours,$t.Minutes,$t.Seconds}
function Get-LoggedOnUserSessions{
  $lines=@()
  try{
    $raw=& "$env:WINDIR\System32\quser.exe" 2>$null
    if($LASTEXITCODE -eq 0 -and $raw){$lines=@($raw|Select-Object -Skip 1|?{-not [string]::IsNullOrWhiteSpace($_)})}
  }catch{
    Log "WARN: query user failed: $_"
  }
  return $lines
}
function Remove-PathSafe([string]$Path){
  if([string]::IsNullOrWhiteSpace($Path)){return}
  try{if(Test-Path -LiteralPath $Path){Remove-Item -LiteralPath $Path -Recurse -Force -ErrorAction Stop}}catch{Log "WARN: remove $Path : $_"}
}
function CopyDir($src,$dst){
  Mk $dst
  Get-ChildItem -LiteralPath $src -Recurse -Force|%{
    $rel=$_.FullName.Substring($src.Length).TrimStart('\');$to=Join-Path $dst $rel
    if($_.PSIsContainer){Mk $to}else{Mk(Split-Path $to -Parent);try{Copy-Item -LiteralPath $_.FullName -Destination $to -Force -ErrorAction Stop}catch{Log "WARN: copy $($_.FullName): $_"}}
  }
}

$script:AccessTokens=@{};$script:AccessTokenExpiresOn=@{}
function GetToken([string]$res='https://storage.azure.com/'){
  if($script:AccessTokens.ContainsKey($res) -and $script:AccessTokenExpiresOn.ContainsKey($res)){
    if((Get-Date).ToUniversalTime().AddMinutes(5) -lt $script:AccessTokenExpiresOn[$res]){return $script:AccessTokens[$res]}
  }
  $tokenUri="http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$([uri]::EscapeDataString($res))"
  $r=Invoke-RestMethod -Method GET -Uri $tokenUri -Headers @{Metadata='true'} -ErrorAction Stop
  if([string]::IsNullOrWhiteSpace($r.access_token)){throw 'IMDS returned no access_token'}
  $script:AccessTokens[$res]=$r.access_token
  try{$script:AccessTokenExpiresOn[$res]=[DateTimeOffset]::FromUnixTimeSeconds([int64]$r.expires_on).UtcDateTime}catch{$script:AccessTokenExpiresOn[$res]=(Get-Date).ToUniversalTime().AddMinutes(45)}
  return $script:AccessTokens[$res]
}
function GetStorageHeaders(){@{Authorization="Bearer $(GetToken)";'x-ms-version'='2020-10-02'}}
function EncodeBlobPath([string]$name){(($name -split '/')|%{[uri]::EscapeDataString($_)}) -join '/'}
function GetMI($url,$dst,[int]$tries=3){
  Mk(Split-Path $dst -Parent);Remove-PathSafe $dst
  for($i=1;$i -le $tries;$i++){
    try{
      Invoke-WebRequest -Method GET -Uri $url -OutFile $dst -Headers (GetStorageHeaders) -UseBasicParsing -ErrorAction Stop
      if((Test-Path $dst) -and ((Get-Item $dst).Length -gt 0)){return $true}
      throw "download created missing or empty file: $dst"
    }catch{
      $statusCode=$null;try{$statusCode=[int]$_.Exception.Response.StatusCode}catch{}
      if($statusCode -eq 404 -or "$_" -match 'BlobNotFound|The specified blob does not exist'){throw "mi download blob not found: $url"}
      Log "WARN: mi download $i $url : $_";Start-Sleep -Seconds (5*$i)
    }
  }
  throw "mi download failed: $url"
}
function ConvertResponseToXml($response){
  $xmlText=$null
  try{
    if($response.RawContentStream){
      $response.RawContentStream.Position=0
      $reader=New-Object System.IO.StreamReader($response.RawContentStream,[Text.Encoding]::UTF8,$true)
      try{$xmlText=$reader.ReadToEnd()}finally{$reader.Dispose()}
    }
  }catch{$xmlText=$null}
  if([string]::IsNullOrWhiteSpace($xmlText)){$xmlText=[string]$response.Content}
  $xmlText=$xmlText.TrimStart([char]0xFEFF,[char]0x200B)
  $firstXmlChar=$xmlText.IndexOf('<')
  if($firstXmlChar -gt 0){$xmlText=$xmlText.Substring($firstXmlChar)}
  if($firstXmlChar -lt 0 -or [string]::IsNullOrWhiteSpace($xmlText)){throw 'response did not contain XML content'}
  $x=New-Object System.Xml.XmlDocument;$x.LoadXml($xmlText);return $x
}
function PrefixFromPattern([string]$pattern){$idx=$pattern.IndexOfAny([char[]]'*?[');if($idx -lt 0){return $pattern};return $pattern.Substring(0,$idx)}
function ListBlobNamesMI([string]$container,[string]$prefix=''){
  if([string]::IsNullOrWhiteSpace($StorageAccount)){throw 'StorageAccount parameter is empty'}
  if([string]::IsNullOrWhiteSpace($container)){throw 'container parameter is empty'}
  $all=@();$marker=$null
  do{
    $uri="https://$StorageAccount.blob.core.windows.net/${container}?restype=container&comp=list"
    if(-not [string]::IsNullOrWhiteSpace($prefix)){$uri+="&prefix=$([uri]::EscapeDataString($prefix))"}
    if(-not [string]::IsNullOrWhiteSpace($marker)){$uri+="&marker=$([uri]::EscapeDataString($marker))"}
    try{
      $response=Invoke-WebRequest -Method GET -Uri $uri -Headers (GetStorageHeaders) -UseBasicParsing -ErrorAction Stop
      $x=ConvertResponseToXml $response
    }catch{throw "blob list failed: account=$StorageAccount container=$container prefix='$prefix' uri=$uri error=$($_.Exception.Message)"}
    if($x.EnumerationResults.Blobs.Blob){
      $all+=@($x.EnumerationResults.Blobs.Blob|%{[pscustomobject]@{Name=[string]$_.Name;LastModified=[datetime]$_.Properties.'Last-Modified'}})
    }
    $marker=[string]$x.EnumerationResults.NextMarker
  }while(-not [string]::IsNullOrWhiteSpace($marker))
  return $all
}
function BlobName($container,$pattern){
  $prefix=PrefixFromPattern $pattern
  $matches=@(ListBlobNamesMI $container $prefix|?{$_.Name -like $pattern})
  if(-not $matches -or $matches.Count -eq 0){throw "no blob matched: account=$StorageAccount container=$container pattern=$pattern prefix=$prefix"}
  return ($matches|Sort-Object LastModified -Descending|Select-Object -First 1).Name
}
function GetBlob($container,$name,$dst){
  $encodedName=EncodeBlobPath $name
  $url="https://$StorageAccount.blob.core.windows.net/$container/$encodedName"
  Log "MI REST download account=$StorageAccount container=$container blob=$name"
  GetMI $url $dst|Out-Null
}
function GetPkg($pattern,$dst){
  $containers=@()
  if(-not [string]::IsNullOrWhiteSpace($PackageContainer)){$containers+=$PackageContainer}
  if($containers -notcontains 'packages'){$containers+='packages'}
  if($containers -notcontains 'scripts'){$containers+='scripts'}
  $errors=@()
  foreach($c in $containers){
    try{$n=BlobName $c $pattern;Log "MI REST package matched account=$StorageAccount container=$c blob=$n";GetBlob $c $n $dst;return}
    catch{$errors+="${c}: $($_.Exception.Message)";Log "WARN: package lookup failed in $c for $pattern : $_"}
  }
  throw "package blob not found for pattern '$pattern'. Tried containers: $($containers -join ', '). Details: $($errors -join ' | ')"
}
function GetPkgAny($patterns,$dst){
  $errors=@()
  foreach($pattern in @($patterns)){
    try{GetPkg $pattern $dst;return}catch{$errors+="${pattern}: $($_.Exception.Message)";Log "WARN: package pattern failed for $pattern : $_"}
  }
  throw "package blob not found for any pattern. Tried patterns: $(@($patterns) -join ', '). Details: $($errors -join ' | ')"
}
function GetLocalizationScript($name,$dst){
  GetBlob $LocalizationContainer $name $dst
}
function TryGetLocalizationScript($name,$dst){
  try{
    GetLocalizationScript $name $dst
    return (Test-Path $dst)
  }catch{
    Log "WARN: optional localization script not found or not accessible: $LocalizationContainer/$name : $_"
    return $false
  }
}
function InvokeLocalizationScript([string]$BlobName,[string]$Destination,[string]$Description){
  if([string]::IsNullOrWhiteSpace($BlobName)){Log "$Description script name is empty; skipping";return $false}
  Remove-PathSafe $Destination
  if(-not(TryGetLocalizationScript $BlobName $Destination)){Log "$Description script not found: $LocalizationContainer/$BlobName; skipping";return $false}
  try{
    $item=Get-Item -LiteralPath $Destination -ErrorAction Stop
    if($item.Length -le 0){Log "$Description script is empty: $LocalizationContainer/$BlobName; skipping";Remove-PathSafe $Destination;return $false}
    Unblock-File $Destination -ErrorAction SilentlyContinue
    Log "$Description script running: $LocalizationContainer/$BlobName"
    $p=Start-Process powershell.exe -ArgumentList "-NoProfile -NonInteractive -ExecutionPolicy Bypass -File `"$Destination`"" -Wait -PassThru -WindowStyle Hidden
    if($p.ExitCode -eq 0){Log "$Description script completed: $LocalizationContainer/$BlobName";return $true}
    Log "WARN: $Description script exit $($p.ExitCode): $LocalizationContainer/$BlobName"
    return $false
  }catch{
    Log "WARN: $Description script failed: $LocalizationContainer/$BlobName : $_"
    return $false
  }
}
function InvokeScheduledLocalization{
  Sec 'Windows Localization'
  Mk $LocalizationDir

  $commonRan=$false
  foreach($name in @('localization.ps1','windows-localization.ps1')){
    if(InvokeLocalizationScript $name (Join-Path $LocalizationDir $name) 'OS localization'){
      $commonRan=$true
      break
    }
  }
  if(-not $commonRan){Log 'No common localization script completed'}

  $individualNames=@($env:COMPUTERNAME,$VMName)|?{-not [string]::IsNullOrWhiteSpace($_)}|%{"$_.ps1"}|Select-Object -Unique
  foreach($name in $individualNames){
    InvokeLocalizationScript $name (Join-Path $LocalizationDir $name) 'VM-specific localization'|Out-Null
  }
}

function RunMsi($name,$msi,[int]$tries=5){
  for($i=1;$i -le $tries;$i++){
    $p=Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru -WindowStyle Hidden
    if($p.ExitCode -in 0,3010,1641){return $p.ExitCode}
    if($p.ExitCode -eq 1618 -and $i -lt $tries){$wait=30*$i;Log "WARN: $name MSI exit 1618; retry $($i+1)/$tries in ${wait}s";Start-Sleep -Seconds $wait;continue}
    throw "$name MSI exit $($p.ExitCode)"
  }
}
function MSI($name,$pattern,$detect){
  Sec "Install: $name";$t=Get-Date
  if($detect -and (Test-Path $detect)){Log "$name already present";return}
  $msi=Join-Path $DlDir (($name -replace '[^A-Za-z0-9]','')+'.msi')
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
  $zip=Join-Path $DlDir 'az-modules.zip';$ext=Join-Path $WorkDir 'azmods_extracted'
  if(Test-Path $azAccounts){Log 'Az.Accounts already present for Windows PowerShell 5.1'}else{
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
  $ps51Modules=Join-Path $PF 'WindowsPowerShell\Modules';$ps7Modules=Join-Path $PF 'PowerShell\7\Modules'
  if(-not(Test-Path $PwshExe)){Log "WARN: PowerShell 7 not found at $PwshExe; skipping Az module copy";return}
  Mk $ps7Modules
  $mods=Get-ChildItem -LiteralPath $ps51Modules -Directory -ErrorAction SilentlyContinue|?{$_.Name -like 'Az*'}
  if(-not $mods){Log "WARN: No Az modules found in $ps51Modules; skipping PS 7 copy";return}
  $mods|%{CopyDir $_.FullName (Join-Path $ps7Modules $_.Name)}
  try{& $PwshExe -NoProfile -Command "Import-Module Az.Accounts -ErrorAction Stop; (Get-Module Az.Accounts).Version.ToString()"|%{Log "Az.Accounts PS 7 import version: $_"}}catch{Log "WARN: Az.Accounts PS 7 import: $_"}
  Log "Az Modules PS 7 Copy done $(Dur $t (Get-Date))"
}
function InstallSysinternals{
  Sec 'Sysinternals Suite';$t=Get-Date
  if(Test-Path $SysinternalsDetect){Log "Sysinternals already present at $SysinternalsDetect";return}
  $zip=Join-Path $DlDir 'SysinternalsSuite.zip'
  GetPkg 'SysinternalsSuite*.zip' $zip
  Expand-Archive -Path $zip -DestinationPath $System32 -Force
  if(-not(Test-Path $SysinternalsDetect)){Log "WARN: Sysinternals install could not verify $SysinternalsDetect"}
  try{Unblock-File (Join-Path $System32 '*.exe') -ErrorAction SilentlyContinue}catch{}
  Log "Sysinternals Suite done $(Dur $t (Get-Date))"
}
function InstallGit{
  EXEAny 'Git' @('Git-*-64-bit.exe','Git-*.exe') $GitExe '/VERYSILENT /NORESTART /NOCANCEL /SP-'
}
function InstallPostman{
  Sec 'Postman';$t=Get-Date
  function EnsurePostmanShortcut{
    try{$shell=New-Object -ComObject WScript.Shell;$sc=$shell.CreateShortcut((Join-Path $PUB 'Desktop\Postman.lnk'));$sc.TargetPath=$PostmanExe;$sc.Save();Log 'Postman public desktop shortcut ensured'}catch{Log "WARN: Postman shortcut: $_"}
  }
  function CleanupPostmanDuplicateShortcuts{
    try{
      $publicShortcut=Join-Path $PUB 'Desktop\Postman.lnk'
      if(Test-Path $publicShortcut){
        Get-ChildItem (Join-Path $SD 'Users') -Directory -ErrorAction SilentlyContinue|?{$_.Name -notin @('Public','Default','Default User','All Users')}|%{
          $p=Join-Path $_.FullName 'Desktop\Postman.lnk'
          if(Test-Path $p){Remove-Item $p -Force -ErrorAction SilentlyContinue;Log "Removed Postman shortcut from profile: $($_.Name)"}
        }
      }
    }catch{Log "WARN: Postman duplicate shortcut cleanup: $_"}
  }
  if(Test-Path $PostmanExe){Log 'Postman already present';EnsurePostmanShortcut;CleanupPostmanDuplicateShortcuts;return}
  Get-Process -Name Postman,PostmanAgent -ErrorAction SilentlyContinue|Stop-Process -Force -ErrorAction SilentlyContinue
  $pmExe=Join-Path $DlDir 'Postman-win64-Setup-latest.exe';$pmLocal=Join-Path $env:LOCALAPPDATA 'Postman'
  GetPkg 'Postman-win64-Setup*.exe' $pmExe
  $p=Start-Process -FilePath $pmExe -ArgumentList '--silent' -PassThru -WindowStyle Hidden
  $deadline=(Get-Date).AddMinutes(5)
  while((Get-Date) -lt $deadline){if($p.HasExited -or (Test-Path $pmLocal) -or (Test-Path $PostmanExe)){break};Start-Sleep -Seconds 5}
  if(-not $p.HasExited){try{Stop-Process -Id $p.Id -Force -ErrorAction SilentlyContinue}catch{}}
  if(-not(Test-Path $pmLocal) -and -not(Test-Path $PostmanExe)){
    Log 'WARN: Postman --silent attempt did not complete; trying /S'
    $p2=Start-Process -FilePath $pmExe -ArgumentList '/S' -PassThru -WindowStyle Hidden
    $deadline2=(Get-Date).AddMinutes(3)
    while((Get-Date) -lt $deadline2){if($p2.HasExited -or (Test-Path $pmLocal) -or (Test-Path $PostmanExe)){break};Start-Sleep -Seconds 5}
    if(-not $p2.HasExited){try{Stop-Process -Id $p2.Id -Force -ErrorAction SilentlyContinue}catch{}}
  }
  if(Test-Path $pmLocal){Mk $PostmanDir;CopyDir $pmLocal $PostmanDir}
  if(Test-Path $PostmanExe){EnsurePostmanShortcut;CleanupPostmanDuplicateShortcuts;Log "Postman done $(Dur $t (Get-Date))"}else{Log 'WARN: Postman installation could not be verified; continuing'}
}
function InstallMobaXterm{
  Sec 'MobaXterm';$t=Get-Date
  if(Test-Path $MobaExe){Log 'MobaXterm already present';return}
  $zip=Join-Path $DlDir 'MobaXterm_Installer_latest.zip';$ext=Join-Path $WorkDir 'MobaXterm_Installer_latest'
  GetPkg 'MobaXterm_Installer_v*.zip' $zip
  Remove-PathSafe $ext
  Expand-Archive -Path $zip -DestinationPath $ext -Force
  $msi=Get-ChildItem -LiteralPath $ext -Filter '*.msi' -Recurse -ErrorAction SilentlyContinue|Select-Object -First 1
  if(-not $msi){throw 'MobaXterm MSI not found in archive'}
  RunMsi 'MobaXterm' $msi.FullName|Out-Null
  if(-not(Test-Path $MobaExe)){throw "MobaXterm install did not create expected path: $MobaExe"}
  Log "MobaXterm done $(Dur $t (Get-Date))"
}
function InstallAzCopy{
  Sec 'AzCopy';$t=Get-Date
  if(Test-Path $AzCopyExe){Log 'AzCopy already present';return}
  $zip=Join-Path $DlDir 'azcopy_windows_amd64.zip'
  GetPkg 'azcopy_windows_amd64*.zip' $zip
  Remove-PathSafe $AzCopyDir
  Mk $AzCopyDir
  Expand-Archive -Path $zip -DestinationPath $AzCopyDir -Force
  $found=Get-ChildItem -LiteralPath $AzCopyDir -Recurse -Filter azcopy.exe -ErrorAction SilentlyContinue|Select-Object -First 1
  if(-not $found){throw 'azcopy.exe not found in package'}
  if($found.FullName -ne $AzCopyExe){Copy-Item -LiteralPath $found.FullName -Destination $AzCopyExe -Force}
  if(-not(Test-Path $AzCopyExe)){throw "AzCopy install did not create expected path: $AzCopyExe"}
  Log "AzCopy done $(Dur $t (Get-Date))"
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
  if($changed){[Environment]::SetEnvironmentVariable('Path',($parts -join ';'),'Machine')}
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

Log '===================== Scheduled Script Starts v2.0 compact ====================='
Log "Storage=$StorageAccount PackageContainer=$PackageContainer Temp=$TempRoot"

Sec 'Logged On User Guard'
$loggedOnSessions=@(Get-LoggedOnUserSessions)
if($loggedOnSessions.Count -gt 0){
  Log "Logged on user sessions detected; scheduled installs deferred. Sessions: $($loggedOnSessions -join ' | ')"
  Log 'post-cloud-init remains enabled for a future boot trigger.'
  Exit 0
}
Log 'No logged on user sessions detected; continuing scheduled installs.'

DefOn
try{
  InstallAzModulesPs51
  CopyAzModulesToPs7
  MSI 'AWSCLI' 'AWSCLIV2*.msi' $AwsExe
  InstallGit
  TerraformZip 'terraform*.zip'
  InstallSysinternals
  InstallPostman
  InstallMobaXterm
  InstallAzCopy
}catch{
  Log "ERROR: scheduled software install failed: $_"
  Exit 1
}finally{
  DefOff
}

Sec 'PATH Updates'
try{AddPath @($AwsDir,$AzCliDir,$PwshDir,$GitCmdDir,$TerraformDir,$AzCopyDir)}catch{Log "WARN: PATH: $_"}

try{
  InvokeScheduledLocalization
}catch{
  Log "WARN: Windows localization: $_"
}

Sec 'Disable post-cloud-init task'
try{
  Disable-ScheduledTask -TaskName 'post-cloud-init' -ErrorAction Stop|Out-String|%{if($_.Trim()){Log $_.Trim()}}
  Log 'post-cloud-init disabled after successful scheduled bootstrap'
}catch{
  Log "WARN: Disable post-cloud-init task failed: $_"
}

Log '===================== Scheduled Script Ends v2.0 compact ====================='
