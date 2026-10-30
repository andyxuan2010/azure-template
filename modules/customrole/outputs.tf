output "id" {
  description = "Terraform resource ID for the custom role definition, formatted as role GUID and scope."
  value       = azurerm_role_definition.this.id
}

output "role_definition_id" {
  description = "UUID/GUID identifying the custom role definition."
  value       = azurerm_role_definition.this.role_definition_id
}

output "role_definition_resource_id" {
  description = "Azure Resource Manager resource ID for assigning this custom role."
  value       = azurerm_role_definition.this.role_definition_resource_id
}

output "name" {
  description = "Display name of the custom role definition."
  value       = azurerm_role_definition.this.name
}
