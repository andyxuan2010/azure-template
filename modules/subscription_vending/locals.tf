locals {
  subscription_guid = regex("[0-9a-fA-F-]{36}", var.subscription_alias_enabled ? azurerm_subscription.this[0].subscription_id : var.existing_subscription_id)
  subscription_id   = "/subscriptions/${local.subscription_guid}"

  merged_tags = var.tags
}
