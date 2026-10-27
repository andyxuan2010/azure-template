output "role_definition_resource_id" {
  description = "Azure resource ID of the custom route updater role."
  value       = module.route_updater_role.role_definition_resource_id
}

output "role_assignment_ids" {
  description = "Azure role assignment IDs keyed by assignment name."
  value       = module.route_updater_assignment.role_assignment_ids
}
