data "azuread_group" "app_admin" {
  for_each = local.app_admin_group_names

  display_name = each.value
}

data "azuread_group" "app_user" {
  for_each = local.app_user_group_names

  display_name = each.value
}

resource "random_string" "random" {
  count       = trimspace(var.name) == "" && var.use_random_suffix ? 1 : 0
  length      = 4
  special     = false
  upper       = false
  min_numeric = 1
}

resource "azurerm_resource_group" "this" {
  name       = local.resource_group_name
  location   = local.location_normalized
  managed_by = var.managed_by
  tags       = local.tags

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]

    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }
}

resource "azurerm_management_lock" "this" {
  count = var.enable_lock ? 1 : 0

  name       = local.lock_name_effective
  scope      = azurerm_resource_group.this.id
  lock_level = var.lock_level
  notes      = local.lock_notes_effective
}

resource "azurerm_role_assignment" "app_admin_group" {
  for_each = local.app_admin_group_principal_ids

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Contributor"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "app_user_group" {
  for_each = local.app_user_group_principal_ids

  scope                = azurerm_resource_group.this.id
  role_definition_name = "Reader"
  principal_id         = each.value
  principal_type       = "Group"
}

resource "azurerm_role_assignment" "this" {
  for_each = var.role_assignments

  scope                                  = azurerm_resource_group.this.id
  principal_id                           = each.value.principal_id
  role_definition_id                     = try(each.value.role_definition_id, null)
  role_definition_name                   = try(each.value.role_definition_name, null)
  principal_type                         = try(each.value.principal_type, null)
  description                            = try(each.value.description, null)
  name                                   = try(each.value.name, null)
  condition                              = try(each.value.condition, null)
  condition_version                      = try(each.value.condition_version, null)
  delegated_managed_identity_resource_id = try(each.value.delegated_managed_identity_resource_id, null)
  skip_service_principal_aad_check       = try(each.value.skip_service_principal_aad_check, false)
}
