output "id" {
  description = "Function App resource ID."
  value       = local.function_app.id
}

output "name" {
  description = "Function App name."
  value       = local.function_app.name
}

output "resource_group_name" {
  description = "Resource group name where the Function App is deployed."
  value       = local.resource_group_name
}

output "location" {
  description = "Azure region used by the Function App."
  value       = local.location
}

output "location_code" {
  description = "Short location code used for generated naming."
  value       = local.location_code_resolved
}

output "default_hostname" {
  description = "Default hostname for the Function App."
  value       = local.function_app.default_hostname
}

output "custom_domain_verification_id" {
  description = "Custom domain verification ID for the Function App."
  value       = try(local.function_app.custom_domain_verification_id, null)
  sensitive   = true
}

output "kind" {
  description = "Function App operating system."
  value       = local.is_windows ? "Windows" : "Linux"
}

output "os_type" {
  description = "Function App operating system."
  value       = local.is_windows ? "Windows" : "Linux"
}

output "enabled" {
  description = "Whether the Function App is enabled."
  value       = var.enabled
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = var.public_network_access_enabled
}

output "identity_type" {
  description = "Managed identity type configured on the Function App."
  value       = local.identity_type
}

output "identity_ids" {
  description = "User-assigned managed identity IDs configured on the Function App."
  value       = local.identity_ids
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned managed identity when enabled."
  value       = try(local.function_app.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "Tenant ID of the system-assigned managed identity when enabled."
  value       = try(local.function_app.identity[0].tenant_id, null)
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses for the Function App."
  value       = try(local.function_app.outbound_ip_address_list, [])
}

output "possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses for the Function App."
  value       = try(local.function_app.possible_outbound_ip_address_list, [])
}

output "private_endpoint_id" {
  description = "Private endpoint resource ID when enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_name" {
  description = "Private endpoint name when enabled."
  value       = try(azurerm_private_endpoint.this[0].name, null)
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs associated with the private endpoint."
  value       = local.private_dns_zone_ids
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting resource ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "diagnostics_enabled" {
  description = "Whether diagnostic settings are enabled."
  value       = local.diagnostics_enabled
}

output "service_plan_id" {
  description = "Resolved App Service Plan ID used by the Function App."
  value       = var.service_plan_id
}

output "storage_account_id" {
  description = "Resolved or supplied storage account ID used by the Function App."
  value       = local.storage_account_id
}

output "storage_account_name" {
  description = "Storage account name used by the Function App when applicable."
  value       = local.storage_account_name_resolved
}

output "storage_auth_mode" {
  description = "Storage authentication mode used by the Function App."
  value       = local.storage_auth_mode
}

output "tags" {
  description = "Effective tags applied to resources created by this module."
  value       = local.merged_tags
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "role_assignment_ids" {
  description = "Map of additional role assignment IDs keyed by input key."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of Function App role assignments managed by this module."
  value       = length(azurerm_role_assignment.app_admin_group) + length(azurerm_role_assignment.app_user_group) + length(azurerm_role_assignment.this)
}
