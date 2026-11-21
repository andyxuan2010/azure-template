output "action_ids" {
  description = "Terraform provider action state IDs keyed by the caller-supplied action key."
  value       = { for key, resource in msgraph_resource_action.this : key => resource.id }
}

output "resources" {
  description = "Selected Graph response fields keyed by the caller-supplied resource key."
  value       = { for key, resource in msgraph_resource_action.this : key => resource.output }
}
