output "id" {
  description = "The managed identity resource ID."
  value       = azurerm_user_assigned_identity.this.id
}

output "name" {
  description = "The managed identity name."
  value       = azurerm_user_assigned_identity.this.name
}

output "client_id" {
  description = "The managed identity client ID."
  value       = azurerm_user_assigned_identity.this.client_id
}

output "principal_id" {
  description = "The managed identity principal ID."
  value       = azurerm_user_assigned_identity.this.principal_id
}

output "tenant_id" {
  description = "The managed identity tenant ID."
  value       = azurerm_user_assigned_identity.this.tenant_id
}

output "federated_identity_credential_ids" {
  description = "Federated identity credential resource IDs keyed by credential name."
  value       = { for k, v in azurerm_federated_identity_credential.this : k => v.id }
}

output "role_assignment_ids" {
  description = "Role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "tags" {
  description = "Effective tags applied to the managed identity."
  value       = azurerm_user_assigned_identity.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the managed identity."
  value       = local.merged_tags
}
