# this is the scheduled powershell script
# first run init.ps1, then  scheduled.ps1

$LogFile  = 'C:\Logs\Init\InitLog.txt'
$TempRoot = 'C:\Temp\Bootstrap'
$DlDir    = Join-Path $TempRoot 'dl'
$WorkDir  = Join-Path $TempRoot 'work'

# Function to log messages
# Function Write-Log {
#     param([string]$Message)
#     $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
#     "$TimeStamp - $Message" | Out-File -FilePath $LogFile -Append
# }

function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "$ts - $Message"
}

Write-Log "====================Scheduled Script Starts========================="

try {
    Write-Log "--------------------microsoft-windows-terminal registration starts----------------------"
    $wtWork = Join-Path $WorkDir 'WindowsTerminal'
    $xaml    = Get-ChildItem $wtWork -Filter 'Microsoft.UI.Xaml.*x64*.appx' -Recurse | Select-Object -First 1
    $bundle  = Get-ChildItem $wtWork -Filter '*.msixbundle' -Recurse | Select-Object -First 1
    $license = Get-ChildItem $wtWork -Filter '*_License*.xml' -Recurse | Select-Object -First 1

    if ((Test-Path $bundle.FullName) -and (Test-Path $license.FullName)) {
        Add-AppxPackage -Path $xaml.FullName-ErrorAction SilentlyContinue
        Add-AppxPackage -Path $bundle.FullName-ErrorAction SilentlyContinue
    }
}
Catch {
    Write-Log "ERROR: $_"
    Write-Log "register microsoft-windows-terminal failed"
    Exit 1  # Ensure script exits with an error
}

Write-Log "--------------------Azure Arc Surfacing Cleanup---------------------"
try {
    $step = 'Azure Arc Surfacing Cleanup'
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\ServerManager') {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\ServerManager' -Name 'DoNotPopulateAzureArcTiles' -Value 1 -ErrorAction SilentlyContinue
    }
    if (Test-Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System') {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name 'DisableAzureArcSetup' -Value 1 -ErrorAction SilentlyContinue
    }
    $arcShortcut = 'C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Azure Arc Setup.lnk'
    if (Test-Path $arcShortcut) { Remove-Item $arcShortcut -Force -ErrorAction SilentlyContinue }
} catch { Write-Log "WARN: Azure Arc cleanup: $_" }


# try {

#     Write-Log "--------------------microsoft-windows-terminal starts----------------------"
#     # Download the Microsoft.WindowsTerminal_1.22.10352.0_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip
#     Invoke-WebRequest -Uri https://stccoeiacccnonprod.blob.core.windows.net/scripts/Microsoft.WindowsTerminal_1.22.10352.0_8wekyb3d8bbwe.msixbundle_Windows10_PreinstallKit.zip -OutFile c:\temp\Microsoft.WindowsTerminal.zip
#     Expand-Archive -Path "c:\temp\Microsoft.WindowsTerminal.zip"  -DestinationPath "c:\temp\" -force
#     #nblock-File -Path "C:\temp\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx"
#     #nblock-File -Path "c:\temp\60e81fd657c844c0ba03687c799996d5.msixbundle"
#     Add-AppxPackage -Path "c:\temp\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx"
#     Write-Log "Add package Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx"
#     #DISM /Online /Add-ProvisionedAppxPackage /PackagePath:"c:\temp\Microsoft.UI.Xaml.2.8_8.2501.31001.0_x64__8wekyb3d8bbwe.appx" /SkipLicense /LogPath:$LogFile /LogLevel:4
#     #Add-AppxPackage -Path "c:\temp\60e81fd657c844c0ba03687c799996d5.msixbundle" -Verbose 4>&1 | Out-File -FilePath $LogFile -Append
#     DISM /Online /Add-ProvisionedAppxPackage /PackagePath:"C:\temp\60e81fd657c844c0ba03687c799996d5.msixbundle" /LicensePath:"c:\temp\60e81fd657c844c0ba03687c799996d5_License1.xml"
#     Write-Log "Add package 60e81fd657c844c0ba03687c799996d5.msixbundle"



#     # # Set Windows Terminal as the default terminal app
#     # $settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json"
#     # $settings = Get-Content -Path $settingsPath -Raw | ConvertFrom-Json

#     # # Ensure the "startOnUserLogin" and "defaultProfile" settings are configured
#     # if (-not $settings.startOnUserLogin) {
#     #     $settings | Add-Member -MemberType NoteProperty -Name "startOnUserLogin" -Value $true
#     # }
#     # if (-not $settings.defaultProfile) {
#     #     $settings | Add-Member -MemberType NoteProperty -Name "defaultProfile" -Value "{61c54bbd-c2c6-5271-96e7-009a87ff44bf}" # GUID for Command Prompt
#     # }

#     # # Save the updated settings
#     # $settings | ConvertTo-Json -Depth 10 | Set-Content -Path $settingsPath

#     # Set Windows Terminal as the default terminal app in the system
#     Set-ItemProperty -Path "HKCU:\Console" -Name "DefaultTerminalApp" -Value "WindowsTerminal"
#     Write-Log "--------------------microsoft-windows-terminal ends----------------------"


# }
# Catch {
#     Write-Log "ERROR: $_"
#     Write-Log "install microsoft-windows-terminal failed"
#     Exit 1  # Ensure script exits with an error
# }

# try {
#     Write-Log "-------------------Azure Integration Runtime install starts-----------------------"

#     # URL in your Azure Blob Storage
#     $irUrl = "https://stccoeiacccnonprod.blob.core.windows.net/scripts/IntegrationRuntime_5.56.9318.1.msi"

#     # Temp download path
#     $downloadPath = Join-Path $env:TEMP "IntegrationRuntime_5.56.9318.1.msi"

#     # Download the MSI
#     Invoke-WebRequest -Uri $irUrl -OutFile $downloadPath -UseBasicParsing

#     # Install silently
#     # /i <msi> -> install MSI
#     # /quiet   -> no UI
#     # /norestart -> prevent reboot
#     Start-Process msiexec.exe -ArgumentList "/i `"$downloadPath`" /quiet /norestart" -Wait -Verb RunAs

#     # Cleanup
#     Remove-Item -Path $downloadPath -Force

#     Write-Log "-------------------Azure Integration Runtime install completed-----------------------"
# }
# catch {
#     Write-Log "ERROR: $_"
#     Write-Log "Azure Integration Runtime installation failed"
#     Exit 1
# }

# try {
#     Write-Log "-------------------Azure Integration Runtime install starts-----------------------"

#     # URL in your Azure Blob Storage
#     #$irUrl = "https://stccoeiacccnonprod.blob.core.windows.net/scripts/IntegrationRuntime_5.56.9318.1.msi"

#     # Temp download path
#     $downloadPath = Join-Path ([System.Environment]::GetEnvironmentVariable("TEMP", "Machine")) "IntegrationRuntime_5.56.9318.1.msi"

#     # Validate file existence
#     if (-not (Test-Path $downloadPath)) {
#         Write-Log "ERROR: File not found at $downloadPath. Aborting installation."
#         Exit 1
#     }
#     # Download the MSI
#     # Invoke-WebRequest -Uri $irUrl -OutFile $downloadPath -UseBasicParsing
#     Start-Process msiexec.exe -ArgumentList "/i `"$downloadPath`" /quiet /norestart" -Wait -Verb RunAs
#     az login --identity | Out-File -Append -FilePath $LogFile
#     $gatewayKey = az keyvault secret show --vault-name "kv-ccoe-cc-nonprod" --name "shir-iactest-dev-601-shir-key1" --query value -o tsv
#     #& "$env:AZURE_DATAFACTORY_IR_HOME\PowerShellScript\RegisterIntegrationRuntime.ps1" -gatewayKey $gatewayKey -NodeName $env:COMPUTERNAME -Force
#     & "C:\Program Files\Microsoft Integration Runtime\5.0\PowerShellScript\RegisterIntegrationRuntime.ps1" -gatewayKey $gatewayKey -NodeName $env:COMPUTERNAME -Force
#     # Cleanup
#     Remove-Item -Path $downloadPath -Force
#     Write-Log "-------------------Azure Integration Runtime install completed-----------------------"
# }
# catch {
#     Write-Log "ERROR: $_"
#     Write-Log "Azure Integration Runtime installation failed"
#     Exit 1
# }



try {
    Write-Log "-------------------SQL Server Management Studio install starts-----------------------"

    # URL in your Azure Blob Storage
    #$ssmsUrl = "https://stccoeiacccnonprod.blob.core.windows.net/scripts/vs_SSMS.exe"

    # Temp download path
    $downloadPath = Join-Path ([System.Environment]::GetEnvironmentVariable("TEMP", "Machine")) "vs_SSMS.exe"

    # Validate file existence
    if (-not (Test-Path $downloadPath)) {
        Write-Log "ERROR: File not found at $downloadPath. Aborting installation."
        Exit 1
    }
    # Download installer
    # Invoke-WebRequest -Uri $ssmsUrl -OutFile $downloadPath -UseBasicParsing

    # Silent install
    # /install -> run install
    # /quiet   -> no UI
    # /norestart -> prevent auto-reboot
    #Start-Process -FilePath $downloadPath -ArgumentList "/install /quiet /norestart" -Wait -Verb RunAs

    # Cleanup
    Remove-Item -Path $downloadPath -Force

    Write-Log "-------------------SQL Server Management Studio install completed-----------------------"
}
catch {
    Write-Log "ERROR: $_"
    Write-Log "SQL Server Management Studio installation failed"
    Exit 1
}




Write-Log "-------------------Disable RunAppxInstall task-----------------------"
Disable-ScheduledTask -TaskName "RunAppxInstall" | Out-File -FilePath $LogFile -Append

Write-Log "===================Scheduled Script ended=========================="