locals {
  is_production = contains(["prod"], var.app_env)
  is_staging    = contains(["staging"], var.app_env)
  is_sandbox    = contains(["sbx"], var.app_env)
  is_test       = contains(["test", "qa"], var.app_env)

  iac_key_vault_name                       = trimspace(var.iac_kv)
  iac_key_vault_id                         = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.iac_rg}/providers/Microsoft.KeyVault/vaults/${local.iac_key_vault_name}"
  admin_credentials_key_vault_id_effective = trimspace(var.admin_credentials_key_vault_id) != "" ? trimspace(var.admin_credentials_key_vault_id) : local.iac_key_vault_id
  iac_storage_account_name                 = trimspace(var.iac_st)
  iac_storage_account_id                   = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/resourceGroups/${var.iac_rg}/providers/Microsoft.Storage/storageAccounts/${local.iac_storage_account_name}"
  iac_scripts_container_url                = "https://${local.iac_storage_account_name}.blob.core.windows.net/scripts"
  admin_username_secret_name_effective     = trimspace(var.admin_username_secret_name)
  admin_password_secret_name_effective     = trimspace(var.admin_password_secret_name)
  admin_username_input_effective           = trimspace(var.azure-user)
  admin_password_input_effective           = trimspace(var.azure-password)
  admin_username_input_provided            = local.admin_username_input_effective != ""
  admin_password_input_provided            = trimspace(nonsensitive(var.azure-password)) != ""
  admin_username_secret_lookup_enabled     = !local.admin_username_input_provided && local.admin_username_secret_name_effective != ""
  admin_password_secret_lookup_enabled     = !local.admin_password_input_provided && local.admin_password_secret_name_effective != ""
  admin_username_secret_value              = try(trimspace(data.azurerm_key_vault_secret.azure-user[0].value), "")
  admin_password_secret_value              = try(trimspace(data.azurerm_key_vault_secret.azure-password[0].value), "")
  admin_username_effective = coalesce(
    local.admin_username_input_provided ? local.admin_username_input_effective : null,
    local.admin_username_secret_value != "" ? local.admin_username_secret_value : null,
    null
  )
  admin_password_effective = coalesce(
    local.admin_password_input_provided ? local.admin_password_input_effective : null,
    local.admin_password_secret_value != "" ? local.admin_password_secret_value : null,
    null
  )

  vm_remote_group_object_id = local.vm_remote_group_value == "" ? null : (
    can(regex("^[0-9a-fA-F-]{36}$", local.vm_remote_group_value)) ? data.azuread_group.vm_remote_group_by_id[0].object_id : data.azuread_group.vm_remote_group_by_name[0].object_id
  )
  vm_admin_group_object_id = local.vm_admin_group_value == "" ? null : (
    can(regex("^[0-9a-fA-F-]{36}$", local.vm_admin_group_value)) ? data.azuread_group.vm_admin_group_by_id[0].object_id : data.azuread_group.vm_admin_group_by_name[0].object_id
  )
  app_admin_group_object_ids = merge(
    { for group in var.app_admin_group : group => group if can(regex("^[0-9a-fA-F-]{36}$", group)) },
    { for key, group in data.azuread_group.app_admin_group_by_name : key => group.object_id }
  )
  app_user_group_object_ids = merge(
    { for group in var.app_user_group : group => group if can(regex("^[0-9a-fA-F-]{36}$", group)) },
    { for key, group in data.azuread_group.app_user_group_by_name : key => group.object_id }
  )
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
  zone_spread_enabled = var.enable_zone_spread && var.app_vm_number > 1
  vm_zones = {
    for vm_index in range(var.app_vm_number) :
    vm_index => (local.zone_spread_enabled ? var.availability_zones[vm_index % length(var.availability_zones)] : null)
  }

  environment_tags = {
    prod    = { Environment = "Production", CostCenter = "Operations" }
    staging = { Environment = "Staging", CostCenter = "Operations" }
    dev     = { Environment = "Development", CostCenter = "Development" }
    sbx     = { Environment = "Sandbox", CostCenter = "Development" }
    test    = { Environment = "Test", CostCenter = "QA" }
    qa      = { Environment = "QA", CostCenter = "QA" }
  }

  merged_tags = merge(
    lookup(local.environment_tags, var.app_env, {}),
    var.tags
  )
}
