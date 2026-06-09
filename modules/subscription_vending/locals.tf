locals {
  environment_tag_map = {
    prod = "PROD"
    dev  = "DEV"
    qa   = "QA"
    test = "TEST"
    sbx  = "SBX"
    poc  = "POC"
  }

  subscription_guid = regex("[0-9a-fA-F-]{36}", var.subscription_alias_enabled ? azurerm_subscription.this[0].subscription_id : var.existing_subscription_id)
  subscription_id   = "/subscriptions/${local.subscription_guid}"

  mandatory_tags = {
    Environment = lookup(local.environment_tag_map, lower(trimspace(var.app_env)), upper(trimspace(var.app_env)))
    Workload    = trimspace(var.workload)
  }

  merged_tags = merge(
    var.tags,
    local.mandatory_tags,
  )
}
