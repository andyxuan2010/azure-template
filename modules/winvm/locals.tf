locals {
  is_production = contains(["prod"], var.app_env)
  is_staging    = contains(["staging"], var.app_env)
  is_sandbox    = contains(["sbx"], var.app_env)
  is_test       = contains(["test", "qa"], var.app_env)

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
    { ManagedBy = "Terraform" },
    var.tags
  )
}
