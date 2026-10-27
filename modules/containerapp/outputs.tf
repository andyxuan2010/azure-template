output "id" {
  description = "Container App ID."
  value       = azurerm_container_app.this.id
}

output "name" {
  description = "Container App name."
  value       = azurerm_container_app.this.name
}

output "resource_group_name" {
  description = "Resource group containing the Container App."
  value       = azurerm_container_app.this.resource_group_name
}

output "container_app_environment_id" {
  description = "Container Apps managed environment ID."
  value       = azurerm_container_app.this.container_app_environment_id
}

output "location" {
  description = "Resolved Azure region."
  value       = local.location
}

output "latest_revision_name" {
  description = "Latest revision name."
  value       = azurerm_container_app.this.latest_revision_name
}

output "latest_revision_fqdn" {
  description = "Latest revision FQDN."
  value       = azurerm_container_app.this.latest_revision_fqdn
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses assigned to the Container App."
  value       = azurerm_container_app.this.outbound_ip_addresses
}

output "identity_type" {
  description = "Managed identity type configured on the Container App."
  value       = var.identity_type
}

output "principal_id" {
  description = "System-assigned managed identity principal ID when enabled."
  value       = try(azurerm_container_app.this.identity[0].principal_id, null)
}

output "tags" {
  description = "Effective tags applied to the Container App."
  value       = local.tags
}
