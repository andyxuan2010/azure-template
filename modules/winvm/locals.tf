locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  is_production = contains(["prod"], var.app_env)
  is_staging    = contains(["staging"], var.app_env)
  is_sandbox    = contains(["sbx"], var.app_env)
  is_test       = contains(["test", "qa"], var.app_env)

  iac_key_vault_name                         = trimspace(var.iac_kv)
  iac_key_vault_id                           = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.iac_rg}/providers/Microsoft.KeyVault/vaults/${local.iac_key_vault_name}"
  admin_credentials_key_vault_id_effective   = trimspace(var.admin_credentials_key_vault_id) != "" ? trimspace(var.admin_credentials_key_vault_id) : local.iac_key_vault_id
  iac_storage_account_name                   = trimspace(var.iac_st)
  iac_storage_account_id                     = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.iac_rg}/providers/Microsoft.Storage/storageAccounts/${local.iac_storage_account_name}"
  iac_scripts_container_url                  = "https://${local.iac_storage_account_name}.blob.core.windows.net/scripts"
  admin_username_secret_name_effective       = trimspace(var.admin_username_secret_name)
  admin_password_secret_name_effective       = trimspace(var.admin_password_secret_name)
  admin_username_input_effective             = trimspace(var.azure-user)
  admin_password_input_effective             = trimspace(var.azure-password)
  admin_username_input_provided              = local.admin_username_input_effective != ""
  admin_password_input_provided              = trimspace(nonsensitive(var.azure-password)) != ""
  admin_username_secret_lookup_enabled       = !local.admin_username_input_provided && local.admin_username_secret_name_effective != ""
  admin_password_secret_lookup_enabled       = !local.admin_password_input_provided && local.admin_password_secret_name_effective != ""
  admin_username_secret_value                = try(trimspace(data.azurerm_key_vault_secret.azure-user[0].value), "")
  admin_password_secret_value                = try(trimspace(data.azurerm_key_vault_secret.azure-password[0].value), "")
  domain_join_username_secret_name_effective = trimspace(var.domain_join_username_secret_name)
  domain_join_password_secret_name_effective = trimspace(var.domain_join_password_secret_name)
  domain_join_username_input_effective       = trimspace(var.domain_join_user)
  domain_join_password_input_effective       = trimspace(var.domain_join_password)
  domain_join_username_input_provided        = local.domain_join_username_input_effective != ""
  domain_join_password_input_provided        = trimspace(nonsensitive(var.domain_join_password)) != ""
  domain_join_secret_lookup_allowed          = var.enable_domain_join && var.app_env != "sbx"
  domain_join_username_secret_lookup_enabled = local.domain_join_secret_lookup_allowed && !local.domain_join_username_input_provided && local.domain_join_username_secret_name_effective != ""
  domain_join_password_secret_lookup_enabled = local.domain_join_secret_lookup_allowed && !local.domain_join_password_input_provided && local.domain_join_password_secret_name_effective != ""
  domain_join_username_secret_value          = try(trimspace(data.azurerm_key_vault_secret.domain_join_user[0].value), "")
  domain_join_password_secret_value          = try(trimspace(data.azurerm_key_vault_secret.domain_join_password[0].value), "")
  admin_username_effective = try(coalesce(
    local.admin_username_input_provided ? local.admin_username_input_effective : null,
    local.admin_username_secret_value != "" ? local.admin_username_secret_value : null
  ), null)
  admin_password_effective = try(coalesce(
    local.admin_password_input_provided ? local.admin_password_input_effective : null,
    local.admin_password_secret_value != "" ? local.admin_password_secret_value : null
  ), null)
  domain_join_username_effective = try(coalesce(
    local.domain_join_username_input_provided ? local.domain_join_username_input_effective : null,
    local.domain_join_username_secret_value != "" ? local.domain_join_username_secret_value : null
  ), null)
  domain_join_password_effective = try(coalesce(
    local.domain_join_password_input_provided ? local.domain_join_password_input_effective : null,
    local.domain_join_password_secret_value != "" ? local.domain_join_password_secret_value : null
  ), null)
  init2_domain_join_active     = !var.enable_domain_join && var.init2_enable_domain_join
  primary_dns_suffix_effective = lower(trimspace(var.primary_dns_suffix))
  primary_dns_suffix_script    = <<-POWERSHELL
    $ErrorActionPreference = 'Stop'
    $suffix = '${lower(trimspace(var.primary_dns_suffix))}'
    $registryPath = 'HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters'
    $currentSuffix = (Get-ItemProperty -Path $registryPath -Name 'NV Domain' -ErrorAction SilentlyContinue).'NV Domain'

    if ($currentSuffix -ine $suffix) {
      Set-ItemProperty -Path $registryPath -Name 'NV Domain' -Value $suffix -Type String
      Set-ItemProperty -Path $registryPath -Name 'Domain' -Value $suffix -Type String
      & shutdown.exe /r /t 60 /d p:2:4 /c 'Terraform changed the Windows primary DNS suffix.'
      if ($LASTEXITCODE -ne 0) { throw "Unable to schedule the restart required for the primary DNS suffix change." }
    }
  POWERSHELL

  vm_remote_group_object_id = local.vm_remote_group_value == "" ? null : (
    can(regex("^[0-9a-fA-F-]{36}$", local.vm_remote_group_value)) ? data.azuread_group.vm_remote_group_by_id[0].object_id : data.azuread_group.vm_remote_group_by_name[0].object_id
  )
  vm_admin_group_object_id = local.vm_admin_group_value == "" ? null : (
    can(regex("^[0-9a-fA-F-]{36}$", local.vm_admin_group_value)) ? data.azuread_group.vm_admin_group_by_id[0].object_id : data.azuread_group.vm_admin_group_by_name[0].object_id
  )
  app_admin_group_values = [
    for group in(var.app_admin_group == null ? [] : var.app_admin_group) : try(trimspace(group), "")
    if try(trimspace(group), "") != ""
  ]
  app_user_group_values = [
    for group in(var.app_user_group == null ? [] : var.app_user_group) : try(trimspace(group), "")
    if try(trimspace(group), "") != ""
  ]
  windows_group_domain_prefix_effective = replace(trimspace(var.windows_group_domain_prefix), "/\\\\+$/", "")
  app_admin_group_object_ids = merge(
    { for group in local.app_admin_group_values : group => group if can(regex("^[0-9a-fA-F-]{36}$", group)) },
    { for key, group in data.azuread_group.app_admin_group_by_name : key => group.object_id }
  )
  app_user_group_object_ids = merge(
    { for group in local.app_user_group_values : group => group if can(regex("^[0-9a-fA-F-]{36}$", group)) },
    { for key, group in data.azuread_group.app_user_group_by_name : key => group.object_id }
  )
  app_admin_group_windows_base_values = distinct([
    for group in local.app_admin_group_values :
    can(regex("^[0-9a-fA-F-]{36}$", group)) ? data.azuread_group.app_admin_group_by_id[group].display_name : group
  ])
  app_user_group_windows_base_values = distinct([
    for group in local.app_user_group_values :
    can(regex("^[0-9a-fA-F-]{36}$", group)) ? data.azuread_group.app_user_group_by_id[group].display_name : group
  ])
  app_admin_group_windows_values = distinct([
    for group in local.app_admin_group_windows_base_values :
    local.windows_group_domain_prefix_effective != "" && !can(regex("\\\\", group)) && !can(regex("^S-1-", group))
    ? "${local.windows_group_domain_prefix_effective}\\${group}"
    : group
  ])
  app_user_group_windows_values = distinct([
    for group in local.app_user_group_windows_base_values :
    local.windows_group_domain_prefix_effective != "" && !can(regex("\\\\", group)) && !can(regex("^S-1-", group))
    ? "${local.windows_group_domain_prefix_effective}\\${group}"
    : group
  ])
  vm_login_admin_group_object_ids = merge(
    local.app_admin_group_object_ids,
    local.vm_admin_group_object_id == null ? {} : { vm_admin_group = local.vm_admin_group_object_id }
  )
  vm_login_user_group_object_ids = merge(
    local.app_user_group_object_ids,
    local.vm_remote_group_object_id == null ? {} : { vm_remote_group = local.vm_remote_group_object_id }
  )
  vm_login_admin_role_assignments = merge([
    for vm_index in range(var.app_vm_number) : {
      for group_key, principal_id in local.vm_login_admin_group_object_ids :
      "${vm_index}|${group_key}" => {
        vm_index     = vm_index
        principal_id = principal_id
      }
    }
  ]...)
  vm_login_user_role_assignments = merge([
    for vm_index in range(var.app_vm_number) : {
      for group_key, principal_id in local.vm_login_user_group_object_ids :
      "${vm_index}|${group_key}" => {
        vm_index     = vm_index
        principal_id = principal_id
      }
    }
  ]...)
  vm_resource_admin_role_assignments = merge([
    for vm_index in range(var.app_vm_number) : {
      for group_key, principal_id in local.app_admin_group_object_ids :
      "${vm_index}|${group_key}" => {
        vm_index     = vm_index
        principal_id = principal_id
      }
    }
  ]...)
  vm_resource_user_role_assignments = merge([
    for vm_index in range(var.app_vm_number) : {
      for group_key, principal_id in local.app_user_group_object_ids :
      "${vm_index}|${group_key}" => {
        vm_index     = vm_index
        principal_id = principal_id
      }
    }
  ]...)
  zone_spread_enabled = var.availability_set_id == null && var.enable_zone_spread && var.app_vm_number > 1
  vm_zones = {
    for vm_index in range(var.app_vm_number) :
    vm_index => (local.zone_spread_enabled ? var.availability_zones[vm_index % length(var.availability_zones)] : null)
  }

  tags = merge(
    var.inherit_resource_group_tags ? coalesce(var.inherited_resource_group_tags, try(data.azurerm_resource_group.app.tags, {})) : {},
    var.tags
  )
}
