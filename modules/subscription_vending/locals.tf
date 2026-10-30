locals {
  workload_code     = lower(join("", regexall("[a-z0-9-]", trimspace(var.workload))))
  subscription_name = trimspace(var.name) != "" ? trimspace(var.name) : (trimspace(var.subscription_name) != "" ? trimspace(var.subscription_name) : substr("sub-${local.workload_code}-${var.app_env}-${trimspace(var.instance)}", 0, 64))

  subscription_guid = regex("[0-9a-fA-F-]{36}", var.subscription_alias_enabled ? azurerm_subscription.this[0].subscription_id : var.existing_subscription_id)
  subscription_id   = "/subscriptions/${local.subscription_guid}"

  merged_tags = var.tags
}
