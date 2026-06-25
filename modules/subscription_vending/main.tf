resource "azurerm_subscription" "this" {
  count = var.subscription_alias_enabled ? 1 : 0

  subscription_name = var.subscription_name
  alias             = var.subscription_alias_name
  billing_scope_id  = var.billing_scope_id
}

resource "azurerm_management_group_subscription_association" "this" {
  count = var.enable_management_group_association ? 1 : 0

  management_group_id = var.management_group_id
  subscription_id     = local.subscription_id
}

resource "azurerm_resource_provider_registration" "this" {
  for_each = toset(var.resource_provider_registrations)

  name = each.value
}

resource "azurerm_resource_group" "bootstrap" {
  for_each = var.bootstrap_resource_groups

  name     = each.value.name
  location = each.value.location
  tags     = merge(local.merged_tags, each.value.tags)
}
