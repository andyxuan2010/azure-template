output "id" {
  description = "Resource group ID."
  value       = module.resource_group.id
}

output "name" {
  description = "Generated resource group name."
  value       = module.resource_group.name
}

output "location_code" {
  description = "Resolved location code."
  value       = module.resource_group.location_code
}
