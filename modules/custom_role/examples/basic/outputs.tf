output "role_definition_resource_id" {
  description = "Azure resource ID to pass to the roleassignments module."
  value       = module.route_updater_role.role_definition_resource_id
}
