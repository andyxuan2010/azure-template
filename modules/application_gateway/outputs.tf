output "id" {
  description = "Application Gateway ID."
  value       = azurerm_application_gateway.this.id
}

output "name" {
  description = "Application Gateway name."
  value       = azurerm_application_gateway.this.name
}

output "resource_group_name" {
  description = "Resource group name containing the Application Gateway."
  value       = azurerm_application_gateway.this.resource_group_name
}

output "location" {
  description = "Azure region of the Application Gateway."
  value       = azurerm_application_gateway.this.location
}

output "public_ip_id" {
  description = "Public IP ID attached to the Application Gateway frontend."
  value       = azurerm_public_ip.this.id
}

output "public_ip_address" {
  description = "Public IP address attached to the Application Gateway frontend."
  value       = azurerm_public_ip.this.ip_address
}

output "frontend_ip_configuration_name" {
  description = "Frontend IP configuration name exposed by this module."
  value       = local.frontend_ip_configuration_name
}

output "backend_address_pool_names" {
  description = "Backend address pool names defined on the Application Gateway."
  value       = [for p in azurerm_application_gateway.this.backend_address_pool : p.name]
}

output "backend_http_settings_names" {
  description = "Backend HTTP settings names defined on the Application Gateway."
  value       = [for s in azurerm_application_gateway.this.backend_http_settings : s.name]
}

output "http_listener_names" {
  description = "HTTP listener names defined on the Application Gateway."
  value       = [for l in azurerm_application_gateway.this.http_listener : l.name]
}

output "request_routing_rule_names" {
  description = "Request routing rule names defined on the Application Gateway."
  value       = [for r in azurerm_application_gateway.this.request_routing_rule : r.name]
}

output "url_path_map_names" {
  description = "URL path map names defined on the Application Gateway."
  value       = [for path_map in azurerm_application_gateway.this.url_path_map : path_map.name]
}

output "diagnostic_setting_id" {
  description = "Application Gateway diagnostic setting ID, or null when diagnostics are not configured."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "Effective tags applied to the Application Gateway."
  value       = azurerm_application_gateway.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to Application Gateway resources."
  value       = local.merged_tags
}
