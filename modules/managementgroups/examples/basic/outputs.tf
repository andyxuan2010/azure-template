output "management_group_id" {
  description = "Resource ID of the management group."
  value       = module.management_group.id
}

output "management_group_name" {
  description = "Stable management group ID/name."
  value       = module.management_group.name
}

output "display_name" {
  description = "Human-readable display name."
  value       = module.management_group.display_name
}
