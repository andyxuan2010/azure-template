output "app_id" {
  description = "The ID of this Web App."
  value       = local.web_app.id
}

output "app_name" {
  description = "The name of this Web App."
  value       = local.web_app.name
}

output "app_kind" {
  description = "The operating system kind of this Web App."
  value       = local.is_windows ? "Windows" : "Linux"
}

output "location" {
  description = "The resolved Azure region used by this Web App."
  value       = local.location
}

output "app_enabled" {
  description = "Whether the Web App is enabled."
  value       = var.app_enabled
}

output "identity_principal_id" {
  description = "The principal ID of the system-assigned identity of this Web App. This value will be null if the system-assigned identity is disabled."
  value       = try(local.web_app.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the system-assigned identity of this Web App. This value will be null if the system-assigned identity is disabled."
  value       = try(local.web_app.identity[0].tenant_id, null)
}

output "default_hostname" {
  description = "The default hostname of this Web App."
  value       = local.web_app.default_hostname
}

output "default_url" {
  description = "The default HTTPS URL of this Web App."
  value       = "https://${local.web_app.default_hostname}"
}

output "outbound_ip_addresses" {
  description = "Comma-separated outbound IP addresses assigned to the Web App."
  value       = local.web_app.outbound_ip_addresses
}

output "possible_outbound_ip_addresses" {
  description = "Comma-separated possible outbound IP addresses for the Web App."
  value       = local.web_app.possible_outbound_ip_addresses
}

output "custom_domain_verification_id" {
  description = "The identifier used by App Service to perform domain ownership verification via DNS TXT record."
  value       = local.web_app.custom_domain_verification_id
  sensitive   = true
}

output "site_credential_name" {
  description = "The Site Credentials Username used for publishing."
  value       = local.web_app.site_credential[0].name
  sensitive   = true
}

output "site_credential_password" {
  description = "The Site Credentials Password used for publishing."
  value       = local.web_app.site_credential[0].password
  sensitive   = true
}

output "merged_tags" {
  description = "Final merged tags applied to resources"
  value       = local.merged_tags
}

output "diagnostics_enabled" {
  description = "Whether any diagnostic log or metric categories were enabled for the app service."
  value       = local.diagnostics_enabled
}

output "diagnostic_log_categories" {
  description = "Effective diagnostic log categories configured by the module."
  value       = local.diagnostic_log_categories
}

output "diagnostic_metric_categories" {
  description = "Effective diagnostic metric categories configured by the module."
  value       = local.diagnostic_metric_categories
}

output "auth_config" {
  description = "Resolved authentication mode flags for the Web App."
  value = {
    easy_auth_enabled = local.easy_auth_enabled
    msal_enabled      = local.msal_enabled
    allow_anonymous   = var.allow_anonymous
  }
}

output "application_insights_id" {
  description = "Resource ID of the Application Insights resource created for this Web App, if enabled."
  value       = try(azurerm_application_insights.this[0].id, null)
}

output "application_insights_name" {
  description = "Name of the Application Insights resource created for this Web App, if enabled."
  value       = try(azurerm_application_insights.this[0].name, null)
}

output "application_insights_connection_string" {
  description = "Connection string for the Application Insights resource created for this Web App, if enabled."
  value       = try(azurerm_application_insights.this[0].connection_string, null)
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Private endpoint
# -----------------------------------------------------------------------------

output "private_endpoint_sites_id" {
  description = "Resource ID of the private endpoint for the app (sites), if created."
  value       = try(azurerm_private_endpoint.sites[0].id, null)
}

# -----------------------------------------------------------------------------
# VNet integration subnet (data structure from lookup)
# -----------------------------------------------------------------------------

output "vnet_integration_subnet_id" {
  description = "Resolved subnet ID used for VNet integration (from variable or from data source lookup by name)."
  value       = local.vnet_integration_subnet_id_resolved
}

output "vnet_integration_subnet" {
  description = "Subnet data structure for VNet integration when looked up by name (id, name, resource_group_name, virtual_network_name, address_prefixes). Null when subnet was provided by ID or when no VNet integration is configured."
  value = length(data.azurerm_subnet.vnet_integration) > 0 ? {
    id                   = data.azurerm_subnet.vnet_integration[0].id
    name                 = data.azurerm_subnet.vnet_integration[0].name
    resource_group_name  = data.azurerm_subnet.vnet_integration[0].resource_group_name
    virtual_network_name = data.azurerm_subnet.vnet_integration[0].virtual_network_name
    address_prefixes     = data.azurerm_subnet.vnet_integration[0].address_prefixes
  } : null
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}
