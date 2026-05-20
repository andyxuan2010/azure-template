output "subscription_id" {
  description = "Subscription ID that was created or targeted."
  value       = local.subscription_id
}

output "subscription_alias_id" {
  description = "Subscription alias resource ID when a new subscription alias is created."
  value       = try(azurerm_subscription.this[0].id, null)
}

output "management_group_subscription_association_id" {
  description = "Management group association resource ID when created."
  value       = try(azurerm_management_group_subscription_association.this[0].id, null)
}

output "registered_resource_providers" {
  description = "Registered resource providers."
  value       = keys(azurerm_resource_provider_registration.this)
}

output "bootstrap_resource_group_ids" {
  description = "Bootstrap resource group IDs keyed by logical name."
  value       = { for k, v in azurerm_resource_group.bootstrap : k => v.id }
}

output "merged_tags" {
  description = "Final merged tags applied to bootstrap resource groups."
  value       = local.merged_tags
}
