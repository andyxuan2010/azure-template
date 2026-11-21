output "resource_ids" {
  description = "Microsoft Graph IDs keyed by the caller-supplied resource key."
  value       = { for key, resource in msgraph_resource.this : key => resource.id }
}

output "resources" {
  description = "Selected Graph response fields keyed by the caller-supplied resource key."
  value       = { for key, resource in msgraph_resource.this : key => resource.output }
}
