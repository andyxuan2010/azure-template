output "subscription_id" {
  description = "Normalized subscription resource ID."
  value       = module.subscription_vending.subscription_id
}

output "management_group_association_id" {
  description = "Management group association resource ID."
  value       = module.subscription_vending.management_group_subscription_association_id
}
