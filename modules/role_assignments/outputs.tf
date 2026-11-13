output "role_assignment_ids" {
  description = "Role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}
