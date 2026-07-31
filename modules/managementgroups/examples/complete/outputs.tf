output "management_group_id" {
  description = "Resource ID of the management group."
  value       = module.management_group.id
}

output "subscription_ids" {
  description = "Normalized subscription IDs managed beneath the group."
  value       = module.management_group.subscription_ids
}

output "metadata" {
  description = "Caller-supplied downstream metadata; these are not Azure tags."
  value       = module.management_group.tags
}
