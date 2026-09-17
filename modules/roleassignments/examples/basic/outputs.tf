output "role_assignment_ids" {
  description = "Role assignment IDs keyed by input assignment name."
  value       = module.role_assignments.role_assignment_ids
}
