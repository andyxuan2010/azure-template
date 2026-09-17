output "subscription_id" {
  description = "Normalized subscription resource ID."
  value       = module.subscription_vending.subscription_id
}

output "registered_resource_providers" {
  description = "Resource providers managed in the subscription."
  value       = module.subscription_vending.registered_resource_providers
}

output "bootstrap_resource_group_ids" {
  description = "Bootstrap resource group IDs keyed by purpose."
  value       = module.subscription_vending.bootstrap_resource_group_ids
}
