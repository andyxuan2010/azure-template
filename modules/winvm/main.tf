locals {
  subscription_map = {
    prod    = "prod"
    staging = "nonprod"
    qa      = "nonprod"
    dev     = "nonprod"
    poc     = "nonprod"
    test    = "nonprod"
    sbx     = "sbx"
  }
  suffix_map = {
    prod    = "001"
    staging = "201"
    qa      = "301"
    dev     = "601"
    poc     = "701"
    test    = "801"
    sbx     = "901"
  }
  subscription = lookup(local.subscription_map, var.app_env, "sbx")
  suffix_base  = tonumber(lookup(local.suffix_map, var.app_env, "000"))
  instance_suffixes = {
    for vm_index in range(var.app_vm_number) :
    vm_index => format("%03d", local.suffix_base + vm_index)
  }
}
# Assuming the resource group has not been created.
# data "azurerm_resource_group" "app" {
#   name = var.app_rg
# }

# resource "azurerm_resource_group" "app" {
#   #count    = length(data.azurerm_resource_group.app) == 0 ? 1 : 0
#   location = var.location
#   name     = var.app_rg
#   tags = merge(var.rg_tags, {
#     name = var.app_rg
#   })
# }

# Assign the Reader role to the AD group for the resource group
# resource "azurerm_role_assignment" "reader" {
#   scope                = data.azurerm_resource_group.app.id
#   role_definition_name = "Reader"
#   principal_id         = data.azuread_group.app.object_id
# }

# locals {
#   app_rg = length(try(data.azurerm_resource_group.app.name, "")) == 0 ? azurerm_resource_group.app[0].name : data.azurerm_resource_group.app.name
# }

# resource "azurerm_virtual_machine_extension" "AADLoginForWindows" {
#   count                      = var.AADLoginForWindows == true ? 1 : 0
#   name                       = "AADLoginForWindows"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.ActiveDirectory"
#   type                       = "AADLoginForWindows"
#   type_handler_version       = "2.2"
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }


# resource "azurerm_virtual_machine_extension" "VMAccessAgent" {
#   name                       = "VMAccessAgent"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "VMAccessAgent"
#   type_handler_version       = "2.4"
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
# }
resource "azurerm_virtual_machine_extension" "NetworkWatcherAgentWindows" {
  count                      = var.app_vm_number
  name                       = "NetworkWatcherAgentWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.NetworkWatcher"
  type                       = "NetworkWatcherAgentWindows"
  type_handler_version       = "1.4"
  auto_upgrade_minor_version = true
  #tags                       = var.rg_tags
  tags = local.tags
  lifecycle {
    ignore_changes = [tags]
  }
  depends_on = [azurerm_windows_virtual_machine.this]
}

# resource "azurerm_virtual_machine_extension" "BGInfo" {
#   name                       = "BGInfo"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Compute"
#   type                       = "BGInfo"
#   type_handler_version       = "2.2.3"
#   tags                       = var.common_tags
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
# }
# resource "azurerm_virtual_machine_extension" "WindowsOpenSSH" {
#   name                       = "WindowsOpenSSH"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.OpenSSH"
#   type                       = "WindowsOpenSSH"
#   type_handler_version       = "3.0"
#   # auto_upgrade_minor_version = true
#   # tags                       = var.rg_tags
#   # depends_on                 = [azurerm_windows_virtual_machine.this]
#   # lifecycle {
#   #   ignore_changes = [tags]
#   # }
# }
# resource "azurerm_virtual_machine_extension" "KeyVaultForWindows" {
#   name                 = "KeyVaultForWindows"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Microsoft.Azure.KeyVault"
#   type                 = "KeyVaultForWindows"
#   type_handler_version = "1.0"
#   auto_upgrade_minor_version = true
#   depends_on           = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource "azurerm_virtual_machine_extension" "AntimalwareConfiguration" {
#   name                 = "AntimalwareConfiguration"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Microsoft.Azure.Security.AntimalwareSignature"
#   type                 = "AntimalwareConfiguration"
#   type_handler_version = "2.159"
#   auto_upgrade_minor_version = true
#   depends_on           = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource "azurerm_virtual_machine_extension" "IaaSAntimalware" {
#   name                       = "IaaSAntimalware"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.Security"
#   type                       = "IaaSAntimalware"
#   type_handler_version       = "1.7"
#   auto_upgrade_minor_version = true
#   settings                   = <<SETTINGS
#         {
#           "AntimalwareEnabled": true,
#           "RealtimeProtectionEnabled": "true",
#           "ScheduledScanSettings": {
#             "isEnabled": "true",
#             "day": "7",
#             "time": "120",
#             "scanType": "quick"
#           },
#           "Exclusions": {
#             "Extensions": "",
#             "Paths": "",
#             "Processes": ""
#           }
#         }
#   SETTINGS
#   tags                       = var.rg_tags
#   depends_on                 = [azurerm_windows_virtual_machine.this]
# }
# resource "azurerm_virtual_machine_extension" "DatadogWindowsAgent" {
#   name                       = "DDAgentExtension"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Datadog.Agent"
#   type                       = "DatadogWindowsAgent"
#   type_handler_version       = "7.0"
#   auto_upgrade_minor_version = true
#   depends_on                 = [azurerm_windows_virtual_machine.this]
#   tags                       = var.rg_tags
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }
# resource "azurerm_virtual_machine_extension" "QualysAgent" {
#   name                 = "QualysWindowsAgent"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Qualys"
#   type                 = "QualysAgent"
#   type_handler_version = "3.1"
#   auto_upgrade_minor_version = true
#   tags                       = var.rg_tags
#   depends_on           = [azurerm_windows_virtual_machine.this]
# }
# resource "azurerm_virtual_machine_extension" "AzureMonitorWindowsAgent" {
#   name                       = "AzureMonitorWindowsAgent"
#   virtual_machine_id         = azurerm_windows_virtual_machine.this.id
#   publisher                  = "Microsoft.Azure.Monitor"
#   type                       = "AzureMonitorWindowsAgent"
#   type_handler_version       = "1.23"
#   auto_upgrade_minor_version = true
#   tags                       = var.rg_tags
#   depends_on                 = [azurerm_windows_virtual_machine.this]
#   lifecycle {
#     ignore_changes = [tags]
#   }
# }

# resource "azurerm_virtual_machine_extension" "VMAccessAgent" {
#   name                 = "VMAccessAgent"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this.id
#   publisher            = "Microsoft.Compute"
#   type                 = "VMAccessAgent"
#   type_handler_version = "2.*"
#   auto_upgrade_minor_version = true
#   tags = var.common_tags
#   depends_on           = [azurerm_windows_virtual_machine.this]
# }

# Create network interface if we need to have a static ip
resource "azurerm_network_interface" "this" {
  count               = var.app_vm_number
  name                = "nic-${var.app_vm}${local.instance_suffixes[count.index]}"
  location            = var.location
  resource_group_name = var.app_rg

  ip_configuration {
    name                          = "nicconfig-${var.app_vm}${local.instance_suffixes[count.index]}"
    subnet_id                     = data.azurerm_subnet.app.id
    public_ip_address_id          = var.public_network_enabled ? azurerm_public_ip.this[count.index].id : null
    private_ip_address_allocation = length(var.private_ip_addresses) > 0 ? "Static" : "Dynamic"
    private_ip_address            = length(var.private_ip_addresses) > 0 ? try(var.private_ip_addresses[count.index], null) : null
  }


  #tags       = var.rg_tags
  tags       = local.tags
  depends_on = [data.azurerm_resource_group.app]

  lifecycle {
    precondition {
      condition     = length(var.private_ip_addresses) == 0 || length(var.private_ip_addresses) == var.app_vm_number
      error_message = "private_ip_addresses must be empty or contain exactly one IP address per Windows VM."
    }
  }
}

resource "azurerm_virtual_machine_extension" "domain_join_ext" {
  # We don't join the domain in the sandbox environment since AAD is not integrated in sbx env.
  count                      = var.enable_domain_join && var.app_env != "sbx" ? var.app_vm_number : 0
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  name                       = "JsonADDomainExtension"
  publisher                  = "Microsoft.Compute"
  type                       = "JsonADDomainExtension"
  type_handler_version       = "1.3"
  auto_upgrade_minor_version = true
  settings                   = <<SETTINGS
    {
      "Name": "${var.domain}",
      "OUPath": "",
      "User": "${local.domain_join_username_effective}",
      "Restart": "false",
      "Options": "3"
    }
  SETTINGS
  protected_settings = jsonencode({
    Password = local.domain_join_password_effective
  })
  lifecycle {
    # Domain join credentials can rotate in Key Vault without requiring the extension to rerun.
    ignore_changes = [settings, protected_settings]

    precondition {
      condition     = local.domain_join_username_effective != ""
      error_message = "A non-empty domain join username is required when enable_domain_join is true outside sbx. Provide domain_join_user directly or configure admin_credentials_key_vault_id plus domain_join_username_secret_name."
    }

    precondition {
      condition     = local.domain_join_password_effective != ""
      error_message = "A non-empty domain join password is required when enable_domain_join is true outside sbx. Provide domain_join_password directly or configure admin_credentials_key_vault_id plus domain_join_password_secret_name."
    }
  }
  timeouts {
    create = "5m"
    delete = "5m"
  }
  #tags = var.rg_tags
  tags = local.tags
  #depends_on = [azurerm_virtual_machine_extension.CustomScriptInit, azurerm_windows_virtual_machine.this]
  depends_on = [
    azurerm_virtual_machine_extension.NetworkWatcherAgentWindows,
    azurerm_virtual_machine_extension.aad_login
  ]
}

#"AdditionalUsers": ${jsonencode(local.app_admin_group_list)},
//add  patch_mode            = "AutomaticByPlatform"
resource "azurerm_windows_virtual_machine" "this" {
  count               = var.app_vm_number
  name                = "${var.app_vm}${local.instance_suffixes[count.index]}"
  computer_name       = "${var.app_vm}${local.instance_suffixes[count.index]}"
  resource_group_name = var.app_rg
  location            = var.location
  zone                = local.vm_zones[count.index]
  size                = var.app_vm_size
  admin_username      = local.admin_username_effective
  admin_password      = local.admin_password_effective

  bypass_platform_safety_checks_on_user_schedule_enabled = false
  network_interface_ids = [
    azurerm_network_interface.this[count.index].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = var.windows_image_publisher
    offer     = var.windows_image_offer
    sku       = var.windows_image_sku
    version   = var.windows_image_version
  }
  identity {
    type = "SystemAssigned"

  }

  patch_mode            = var.patch_mode
  patch_assessment_mode = var.patch_mode == "AutomaticByPlatform" ? "AutomaticByPlatform" : "ImageDefault"
  # custom_data is a backup plan if the storage account is not accessible
  #custom_data        = base64encode(local.init_script)
  # init2.ps1 is the script that will copy the init.ps1 from the storage account to the local disk and then run it.
  custom_data        = base64encode(file("${path.module}/scripts/init2.ps1"))
  provision_vm_agent = true
  #vm_agent_platform_updates_enabled = true
  #tags               = var.rg_tags
  tags = local.tags

  lifecycle {
    ignore_changes = [
      admin_username,
      admin_password,
      custom_data,
    ]

    precondition {
      condition     = local.admin_username_effective != ""
      error_message = "A non-empty Windows VM admin username is required. Provide azure-user directly or configure admin_credentials_key_vault_id plus admin_username_secret_name."
    }

    precondition {
      condition     = local.admin_password_effective != ""
      error_message = "A non-empty Windows VM admin password is required. Provide azure-password directly or configure admin_credentials_key_vault_id plus admin_password_secret_name."
    }

    precondition {
      condition     = !(var.enable_custom_script_extension && var.enable_virtual_machine_run_command)
      error_message = "enable_custom_script_extension and enable_virtual_machine_run_command are mutually exclusive. Enable only one Windows bootstrap execution method."
    }

    precondition {
      condition     = !var.enable_shir || var.enable_custom_script_extension || var.enable_virtual_machine_run_command
      error_message = "Either enable_custom_script_extension or enable_virtual_machine_run_command must be true when enable_shir is true, because SHIR bootstrap runs through the Windows bootstrap script."
    }
  }
}

resource "azurerm_managed_disk" "this" {
  count                 = var.disksize > 0 ? var.app_vm_number : 0 # Provision only if disksize > 0
  name                  = "disk2-${var.app_vm}${local.instance_suffixes[count.index]}"
  location              = var.location
  resource_group_name   = var.app_rg
  zone                  = local.vm_zones[count.index]
  storage_account_type  = "Standard_LRS"
  create_option         = "Empty"
  network_access_policy = "AllowAll"
  disk_size_gb          = var.disksize
  #tags                  = var.rg_tags
  tags       = local.tags
  depends_on = [data.azurerm_resource_group.app]
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  count              = var.disksize > 0 ? var.app_vm_number : 0 # Attach only if the disk exists
  managed_disk_id    = azurerm_managed_disk.this[count.index].id
  virtual_machine_id = azurerm_windows_virtual_machine.this[count.index].id
  lun                = "0"
  caching            = "ReadWrite"
  depends_on         = [azurerm_managed_disk.this]
}

# these 2 scripts should be identical, but the init.ps1 is the one that will be run by the CustomScriptExtension
# if storage account is not accessible then we may need to use the template_file to create the script.
#      "${local.iac_scripts_container_url}/scheduled.ps1"

locals {
  fileUris = <<EOT
    [
      "${local.iac_scripts_container_url}/init.ps1"
    ]
    EOT
  bootstrap_init_arguments = compact([
    var.enable_shir ? "-EnableSHIR" : "",
    var.enable_defender_performance_mode ? "-EnableDefenderPerformanceMode" : "",
    "-Env '${replace(var.app_env, "'", "''")}'",
    "-RebootWhenDone",
    "-AppRemoteGroup '${replace(local.app_user_group_csv, "'", "''")}'",
    "-AppAdminGroup '${replace(local.app_admin_group_csv, "'", "''")}'",
    "-StorageAccount '${replace(local.iac_storage_account_name, "'", "''")}'",
    "-LocalizationContainer '${replace(var.localization_container_name, "'", "''")}'",
    "-TenantId '${replace(data.azurerm_client_config.current.tenant_id, "'", "''")}'",
  ])
  bootstrap_init_argument_string = join(" ", local.bootstrap_init_arguments)
  run_command_init_arguments = concat(
    var.enable_shir ? ["-EnableSHIR"] : [],
    var.enable_defender_performance_mode ? ["-EnableDefenderPerformanceMode"] : [],
    [
      "-Env", var.app_env,
      "-RebootWhenDone",
      "-AppRemoteGroup", local.app_user_group_csv,
      "-AppAdminGroup", local.app_admin_group_csv,
      "-StorageAccount", local.iac_storage_account_name,
      "-LocalizationContainer", var.localization_container_name,
      "-TenantId", data.azurerm_client_config.current.tenant_id,
    ]
  )
  run_command_init_script = <<EOT
    $scriptPath = Join-Path $env:ProgramData 'Bootstrap\run-command-init2.ps1'
    $scriptDir = Split-Path $scriptPath -Parent
    if (!(Test-Path -Path $scriptDir)) {
        New-Item -ItemType Directory -Path $scriptDir -Force | Out-Null
    }
    $scriptBytes = [System.Convert]::FromBase64String('${filebase64("${path.module}/scripts/init2.ps1")}')
    [System.IO.File]::WriteAllBytes($scriptPath, $scriptBytes)
    $scriptArgsJson = @'
${jsonencode(local.run_command_init_arguments)}
'@
    $scriptArgs = @($scriptArgsJson | ConvertFrom-Json)
    & powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File $scriptPath @scriptArgs
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
    EOT
  init_script             = <<EOT
    # This script is a fallback if the storage account is not accessible.
    # It will copy the script from the custom_data to the local disk and then run it.
    $customData = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${azurerm_windows_virtual_machine.this[0].custom_data}'))
    $customDataPath = "C:\\azuredata"
    $customDataFile = "init.ps1"
    if (!(Test-Path -Path $customDataPath)) {
        New-Item -ItemType Directory -Path $customDataPath
    }
    $fullPath = Join-Path -Path $customDataPath -ChildPath $customDataFile
    $customData | Out-File -FilePath $fullPath -Encoding utf8
    EOT
}

locals {
  app_user_group_list = [
    for group in local.app_user_group_windows_values : trimspace(group)
  ]
  app_admin_group_list = [
    for group in local.app_admin_group_windows_values : trimspace(group)
  ]
  app_user_group_csv  = join(",", distinct(local.app_user_group_list))
  app_admin_group_csv = join(",", local.app_admin_group_list)
}

resource "azurerm_virtual_machine_extension" "aad_login" {
  count                      = var.AADLoginForWindows ? var.app_vm_number : 0
  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true
  tags                       = local.tags
  depends_on                 = [azurerm_virtual_machine_extension.NetworkWatcherAgentWindows]
}

resource "azurerm_virtual_machine_extension" "CustomScriptInit" {
  count                = var.enable_custom_script_extension ? var.app_vm_number : 0
  name                 = "CustomScriptInit"
  virtual_machine_id   = azurerm_windows_virtual_machine.this[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  #auto_upgrade_minor_version = true


  # "fileUris": ${local.fileUris},
  # "commandToExecute": "powershell -ExecutionPolicy Bypass -File init.ps1 -Env ${var.app_env} -RebootWhenDone -AppRemoteGroup ${local.app_user_group_list} -AppAdminGroup ${local.app_admin_group_list} -StorageAccount ${local.iac_storage_account_name}"
  # "managedIdentity" : { "clientId": "${azurerm_windows_virtual_machine.this[count.index].identity.0.principal_id}" }

  # "commandToExecute": "powershell -ExecutionPolicy Bypass -File c:\\users\\azureadmin\\downloads\\script.ps1 -Env ${var.app_env} -RebootWhenDone -AppRemoteGroup ${local.app_user_group_list} -AppAdminGroup ${local.app_admin_group_list} -StorageAccount ${local.iac_storage_account_name}",
  # "script": "${filebase64("${path.module}/scripts/script.ps1")}",
  # "managedIdentity" : {}

  #original one: "commandToExecute": "powershell -command Set-ExecutionPolicy RemoteSigned -force; powershell -command copy-item \"c:\\AzureData\\CustomData.bin\" \"c:\\AzureData\\script.ps1\";\"c:\\AzureData\\script.ps1\""
  # option1: "commandToExecute": "powershell -ExecutionPolicy Bypass -Command \"Set-ExecutionPolicy RemoteSigned -Force; Copy-Item 'c:\\AzureData\\CustomData.bin' 'c:\\AzureData\\script.ps1' -Force; & 'c:\\AzureData\\script.ps1'\""
  # option2:  "commandToExecute": "powershell -ExecutionPolicy Bypass -File c:\\AzureData\\CustomData.bin && powershell -ExecutionPolicy Bypass -File c:\\AzureData\\script.ps1"
  # option3: "commandToExecute": "powershell -ExecutionPolicy Bypass -Command \"Copy-Item 'c:\\AzureData\\CustomData.bin' 'c:\\AzureData\\script.ps1' -Force; & 'c:\\AzureData\\script.ps1'\""


  # "script": "${filebase64("${path.module}/scripts/script.ps1")}"
  # if the storage account is not accessible, then we may need to use the template_file to create the script.
  #"commandToExecute": "powershell -ExecutionPolicy unrestricted -NoProfile -NonInteractive -command \"cp c:/azuredata/customdata.bin c:/azuredata/init.ps1; c:/azuredata/init.ps1\""

  # work example
  # "commandToExecute": "powershell -ExecutionPolicy Bypass -Command \"Set-ExecutionPolicy RemoteSigned -Force; Copy-Item 'c:\\AzureData\\CustomData.bin' 'c:\\AzureData\\script.ps1' -Force; & 'c:\\AzureData\\script.ps1' -Env ${var.app_env} -RebootWhenDone -AppRemoteGroup ${local.app_user_group_list} -AppAdminGroup ${local.app_admin_group_list} -StorageAccount ${local.iac_storage_account_name} \""

  settings = <<SETTINGS
  {
    "commandToExecute": "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command \"Copy-Item 'C:\\AzureData\\CustomData.bin' 'C:\\AzureData\\script.ps1' -Force; & 'C:\\AzureData\\script.ps1' ${local.bootstrap_init_argument_string}\""
  }

  SETTINGS
  timeouts {
    create = "30m" // we don't need these 2 lines since the download issue is fixed.
    update = "30m"
  }

  #"powershell -ExecutionPolicy Bypass -Command \"& { .\\init.ps1; .\\createdbuser.ps1 }\""
  #tags = var.rg_tags
  tags = local.tags
  depends_on = [
    azurerm_virtual_machine_extension.NetworkWatcherAgentWindows,
    azurerm_virtual_machine_extension.aad_login,
    azurerm_virtual_machine_extension.domain_join_ext,
    azurerm_role_assignment.vm2st
  ]
  #depends_on = [azurerm_virtual_machine_extension.domain_join_ext,azurerm_role_assignment.vm2adf]
}

resource "terraform_data" "run_command_replace_trigger" {
  input = var.run_command_replace_trigger
}

resource "azurerm_virtual_machine_run_command" "Init" {
  count              = var.enable_virtual_machine_run_command ? var.app_vm_number : 0
  name               = "RunCommandInit"
  location           = var.location
  virtual_machine_id = azurerm_windows_virtual_machine.this[count.index].id

  source {
    script = local.run_command_init_script
  }

  timeouts {
    create = "30m"
    update = "30m"
  }

  lifecycle {
    replace_triggered_by = [
      terraform_data.run_command_replace_trigger
    ]
  }

  tags = local.tags
  depends_on = [
    azurerm_virtual_machine_extension.NetworkWatcherAgentWindows,
    azurerm_virtual_machine_extension.aad_login,
    azurerm_virtual_machine_extension.domain_join_ext,
    azurerm_role_assignment.vm2st
  ]
}


# resource "azurerm_virtual_machine_extension" "CustomScriptInit2" {
#   count               = var.app_vm_number
#   name                 = "CustomScriptInit2"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"
#   #auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#   {
#     "commandToExecute": "powershell -ExecutionPolicy Bypass -File c:\\users\\azureadmin\\downloads\\script.ps1 -Env ${var.app_env} -RebootWhenDone -AppRemoteGroup ${local.app_user_group_list} -AppAdminGroup ${local.app_admin_group_list} -StorageAccount ${local.iac_storage_account_name}",
#     "script": "${filebase64("${path.module}/scripts/script.ps1")}"
#   }
#   SETTINGS
#   tags = local.tags
#   depends_on = [azurerm_virtual_machine_extension.domain_join_ext,azurerm_role_assignment.vm2st]

# }
# resource "azurerm_virtual_machine_extension" "CustomScriptInit3" {
#   count               = var.app_vm_number
#   name                 = "CustomScriptInit3"
#   virtual_machine_id   = azurerm_windows_virtual_machine.this[count.index].id
#   publisher            = "Microsoft.Compute"
#   type                 = "CustomScriptExtension"
#   type_handler_version = "1.10"
#   #auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#   {
#     "commandToExecute": "powershell -ExecutionPolicy Bypass -File init.ps1 -Env ${var.app_env} -RebootWhenDone -AppRemoteGroup ${local.app_user_group_list} -AppAdminGroup ${local.app_admin_group_list} -StorageAccount ${local.iac_storage_account_name}",
#     "fileUris": ${local.fileUris}
#   }
#   SETTINGS
#   tags = local.tags
#   depends_on = [azurerm_virtual_machine_extension.domain_join_ext,azurerm_role_assignment.vm2st]

# }

resource "azurerm_role_assignment" "vm2st" {
  count = var.app_vm_number
  scope = local.iac_storage_account_id
  #scope                = local.iac_scripts_container_url
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_windows_virtual_machine.this[count.index].identity.0.principal_id
}
# resource "azurerm_role_assignment" "vm2st2" {
#   count               = var.app_vm_number
#   scope = local.iac_storage_account_id
#   #scope                = local.iac_scripts_container_url
#   role_definition_name = "Storage Blob Data List Contributor"
#   principal_id         = azurerm_windows_virtual_machine.this[count.index].identity.0.principal_id
# }

resource "azurerm_role_assignment" "vm2kv" {
  count                = var.app_vm_number
  scope                = local.iac_key_vault_id
  role_definition_name = "Key Vault Reader"
  principal_id         = azurerm_windows_virtual_machine.this[count.index].identity.0.principal_id
}
resource "azurerm_role_assignment" "vm2kvsecrets" {
  count                = var.app_vm_number
  scope                = local.iac_key_vault_id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azurerm_windows_virtual_machine.this[count.index].identity.0.principal_id
}

# Role assignment (now local to winvm)
resource "azurerm_role_assignment" "vm2adf" {
  count                = var.enable_shir ? var.app_vm_number : 0
  scope                = var.adf_id
  role_definition_name = "Data Factory Contributor"
  principal_id         = azurerm_windows_virtual_machine.this[count.index].identity.0.principal_id
}

resource "azurerm_public_ip" "this" {
  count               = var.public_network_enabled ? var.app_vm_number : 0
  name                = "pip-${var.app_vm}${local.instance_suffixes[count.index]}"
  location            = var.location
  resource_group_name = var.app_rg
  allocation_method   = "Static"
  sku                 = "Standard"
  #tags               = var.rg_tags
  tags       = local.tags
  depends_on = [data.azurerm_resource_group.app]
}

resource "azurerm_network_security_group" "this" {
  count               = var.public_network_enabled ? var.app_vm_number : 0
  name                = "nsg-${var.app_vm}${local.instance_suffixes[count.index]}"
  location            = var.location
  resource_group_name = var.app_rg

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefixes    = var.rdp_source_address_prefixes
    destination_address_prefix = "*"
  }

  #tags                = var.rg_tags
  tags       = local.tags
  depends_on = [data.azurerm_resource_group.app]
}

resource "azurerm_network_interface_security_group_association" "this" {
  count = var.public_network_enabled ? var.app_vm_number : 0

  network_interface_id      = azurerm_network_interface.this[count.index].id
  network_security_group_id = azurerm_network_security_group.this[count.index].id
  depends_on                = [azurerm_network_security_group.this, azurerm_network_interface.this]
}


#Assign VM User Login role at VM scope
resource "azurerm_role_assignment" "vm_user_login" {
  for_each             = local.vm_login_user_role_assignments
  scope                = azurerm_windows_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Virtual Machine User Login"
  principal_id         = each.value.principal_id
}
#Assign VM Admin Login role at VM scope
resource "azurerm_role_assignment" "vm_admin_login" {
  for_each             = local.vm_login_admin_role_assignments
  scope                = azurerm_windows_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Virtual Machine Administrator Login"
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "vm_resource_admin" {
  for_each = local.vm_resource_admin_role_assignments

  scope                = azurerm_windows_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Contributor"
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "nic_resource_admin" {
  for_each = local.vm_resource_admin_role_assignments

  scope                = azurerm_network_interface.this[each.value.vm_index].id
  role_definition_name = "Contributor"
  principal_id         = each.value.principal_id
}

resource "azurerm_role_assignment" "vm_resource_user" {
  for_each = local.vm_resource_user_role_assignments

  scope                = azurerm_windows_virtual_machine.this[each.value.vm_index].id
  role_definition_name = "Reader"
  principal_id         = each.value.principal_id
}
