output "id" {
  description = "Resource group ID."
  value       = module.resource_group.id
}

output "lock_id" {
  description = "Management lock ID."
  value       = module.resource_group.lock_id
}

output "role_assignment_count" {
  description = "Total number of requested role assignments."
  value       = module.resource_group.role_assignment_count
}
