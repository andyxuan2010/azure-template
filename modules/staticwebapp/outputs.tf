output "id" {
  description = "The resource ID of the Static Web App."
  value       = azurerm_static_web_app.this.id
}

output "name" {
  description = "The Static Web App name."
  value       = azurerm_static_web_app.this.name
}

output "resource_group_name" {
  description = "The resource group containing the Static Web App."
  value       = azurerm_static_web_app.this.resource_group_name
}

output "location" {
  description = "The Azure region of the Static Web App."
  value       = azurerm_static_web_app.this.location
}

output "default_host_name" {
  description = "The default host name assigned to the Static Web App."
  value       = azurerm_static_web_app.this.default_host_name
}

output "api_key" {
  description = "The Static Web App deployment API key."
  value       = azurerm_static_web_app.this.api_key
  sensitive   = true
}

output "sku_tier" {
  description = "The configured Static Web App SKU tier."
  value       = azurerm_static_web_app.this.sku_tier
}

output "sku_size" {
  description = "The configured Static Web App SKU size."
  value       = azurerm_static_web_app.this.sku_size
}

output "identity_principal_id" {
  description = "The principal ID of the managed identity, if one is configured."
  value       = try(azurerm_static_web_app.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the managed identity, if one is configured."
  value       = try(azurerm_static_web_app.this.identity[0].tenant_id, null)
}

output "tags" {
  description = "The effective tags applied to the Static Web App."
  value       = local.tags
}
