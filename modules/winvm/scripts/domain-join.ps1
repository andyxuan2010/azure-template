<#
Manual Windows domain join helper for Azure VMs.

This script intentionally does not use Az PowerShell modules. It reads Key Vault
secrets through the VM managed identity and the Azure Instance Metadata Service.

Required when credentials are not passed directly:
- VM system-assigned or user-assigned managed identity enabled.
- Managed identity has permission to read the configured Key Vault secrets.
- Network path to Key Vault and the target domain controllers is available.
#>

[CmdletBinding()]
param(
  [string]$DomainName = '2join.us',
  [string]$VaultName = '',
  [string]$UserSecretName = 'domain-join-user',
  [string]$PasswordSecretName = 'domain-join-password',
  [string]$DomainJoinUser = '',
  [string]$DomainJoinPassword = '',
  [string]$OUPath = '',
  [ValidateSet('dev','qa','prod','sbx')]
  [string]$Env = 'dev',
  [switch]$Restart = $false,
  [string]$LogFile = ''
)

try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor 3072 } catch {}

$PD = $env:ProgramData
if(-not $PD){ $PD = Join-Path $env:SystemDrive 'ProgramData' }
if([string]::IsNullOrWhiteSpace($LogFile)){
  $LogFile = Join-Path $PD 'Logs\Init\DomainJoinLog.txt'
}
$LogDir = Split-Path $LogFile -Parent
if(-not(Test-Path -LiteralPath $LogDir)){
  New-Item -ItemType Directory -Path $LogDir -Force | Out-Null
}

function Log([string]$Message){
  Add-Content -Path $LogFile -Value "$((Get-Date).ToString('yyyy-MM-dd HH:mm:ss')) - $Message"
}

$script:AccessTokens = @{}
$script:AccessTokenExpiresOn = @{}

function GetToken([string]$Resource = 'https://vault.azure.net'){
  if($script:AccessTokens.ContainsKey($Resource) -and $script:AccessTokenExpiresOn.ContainsKey($Resource)){
    if((Get-Date).ToUniversalTime().AddMinutes(5) -lt $script:AccessTokenExpiresOn[$Resource]){
      return $script:AccessTokens[$Resource]
    }
  }

  $tokenUri = "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2019-08-01&resource=$([uri]::EscapeDataString($Resource))"

  try{
    $response = Invoke-RestMethod `
      -Method GET `
      -Uri $tokenUri `
      -Headers @{ Metadata = 'true' } `
      -ErrorAction Stop
  }catch{
    throw "Managed identity token request failed. Confirm the VM has managed identity enabled. Error: $($_.Exception.Message)"
  }

  if([string]::IsNullOrWhiteSpace($response.access_token)){
    throw 'IMDS returned no managed identity access token'
  }

  $script:AccessTokens[$Resource] = $response.access_token

  try{
    $epoch = [int64]$response.expires_on
    $script:AccessTokenExpiresOn[$Resource] = [DateTimeOffset]::FromUnixTimeSeconds($epoch).UtcDateTime
  }catch{
    $script:AccessTokenExpiresOn[$Resource] = (Get-Date).ToUniversalTime().AddMinutes(45)
  }

  return $script:AccessTokens[$Resource]
}

function GetKeyVaultSecretMI([string]$TargetVaultName, [string]$SecretName){
  if([string]::IsNullOrWhiteSpace($TargetVaultName)){ throw 'Key Vault name is empty' }
  if([string]::IsNullOrWhiteSpace($SecretName)){ throw 'Key Vault secret name is empty' }

  $encodedSecretName = [uri]::EscapeDataString($SecretName)
  $uri = "https://$TargetVaultName.vault.azure.net/secrets/$encodedSecretName`?api-version=7.4"

  try{
    $response = Invoke-RestMethod `
      -Method GET `
      -Uri $uri `
      -Headers @{ Authorization = "Bearer $(GetToken 'https://vault.azure.net')" } `
      -ErrorAction Stop
  }catch{
    throw "Key Vault secret read failed for '$SecretName' in '$TargetVaultName'. Confirm managed identity secret permissions and network access. Error: $($_.Exception.Message)"
  }

  if([string]::IsNullOrWhiteSpace($response.value)){
    throw "Key Vault secret '$SecretName' in '$TargetVaultName' is empty"
  }

  return [string]$response.value
}

function GetDefaultVaultName([string]$EnvironmentName){
  $subscriptionSuffix = switch($EnvironmentName){
    'dev' { 'nonprod' }
    'qa' { 'nonprod' }
    'prod' { 'prod-001' }
    default { 'sbx' }
  }

  return "kv-ccoe-cc-$subscriptionSuffix"
}

Log '===================== Domain Join Script Starts ====================='

try{
  if([string]::IsNullOrWhiteSpace($DomainName)){
    throw 'DomainName is required'
  }

  if([string]::IsNullOrWhiteSpace($VaultName)){
    $VaultName = GetDefaultVaultName $Env
    Log "VaultName was not supplied; using default '$VaultName' for Env '$Env'"
  }

  $computer = Get-CimInstance -ClassName Win32_ComputerSystem -ErrorAction Stop
  if($computer.PartOfDomain){
    if($computer.Domain -ieq $DomainName){
      Log "Computer is already joined to '$DomainName'; no action required"
      Write-Host "Already joined to $DomainName"
      exit 0
    }

    throw "Computer is already joined to '$($computer.Domain)', not '$DomainName'. Unjoin/rejoin is not performed by this helper."
  }

  if([string]::IsNullOrWhiteSpace($DomainJoinUser)){
    Log "Reading domain join username from Key Vault '$VaultName' secret '$UserSecretName'"
    $DomainJoinUser = GetKeyVaultSecretMI -TargetVaultName $VaultName -SecretName $UserSecretName
  }else{
    Log 'Using domain join username supplied as a parameter'
  }

  if([string]::IsNullOrWhiteSpace($DomainJoinPassword)){
    Log "Reading domain join password from Key Vault '$VaultName' secret '$PasswordSecretName'"
    $DomainJoinPassword = GetKeyVaultSecretMI -TargetVaultName $VaultName -SecretName $PasswordSecretName
  }else{
    Log 'Using domain join password supplied as a parameter'
  }

  if([string]::IsNullOrWhiteSpace($DomainJoinUser)){ throw 'Domain join username is empty' }
  if([string]::IsNullOrWhiteSpace($DomainJoinPassword)){ throw 'Domain join password is empty' }

  $securePassword = ConvertTo-SecureString $DomainJoinPassword -AsPlainText -Force
  $credential = New-Object System.Management.Automation.PSCredential($DomainJoinUser, $securePassword)

  $args = @{
    DomainName = $DomainName
    Credential = $credential
    ErrorAction = 'Stop'
  }
  if(-not [string]::IsNullOrWhiteSpace($OUPath)){
    $args.OUPath = $OUPath
  }
  if($Restart){
    $args.Restart = $true
  }

  Log "Joining '$env:COMPUTERNAME' to domain '$DomainName'"
  Add-Computer @args

  if($Restart){
    Log 'Domain join command completed; restart requested'
    Write-Host "Domain join submitted for $DomainName. Restart requested."
  }else{
    Log 'Domain join command completed; restart was not requested'
    Write-Host "Domain join submitted for $DomainName. Restart the VM to complete the join."
  }
}catch{
  Log "ERROR: $_"
  throw
}finally{
  Log '===================== Domain Join Script Ends ====================='
}
