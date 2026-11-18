output "subscription_id" {
  description = "New subscription resource ID used to configure the stage-two provider."
  value       = module.subscription_alias.subscription_id
}

output "subscription_alias_id" {
  description = "Subscription alias resource ID."
  value       = module.subscription_alias.subscription_alias_id
}
