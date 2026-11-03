output "id" {
  description = "Function App resource ID."
  value       = azurerm_function_app_flex_consumption.this.id
}

output "name" {
  description = "Function App name."
  value       = azurerm_function_app_flex_consumption.this.name
}

output "resource_group_name" {
  description = "Resource group containing the Function App."
  value       = azurerm_function_app_flex_consumption.this.resource_group_name
}

output "location" {
  description = "Azure region used by the Function App."
  value       = azurerm_function_app_flex_consumption.this.location
}

output "default_hostname" {
  description = "Default hostname for the Function App."
  value       = azurerm_function_app_flex_consumption.this.default_hostname
}

output "custom_domain_verification_id" {
  description = "Custom domain verification ID for the Function App."
  value       = azurerm_function_app_flex_consumption.this.custom_domain_verification_id
  sensitive   = true
}

output "runtime_name" {
  description = "Flex Consumption runtime name."
  value       = azurerm_function_app_flex_consumption.this.runtime_name
}

output "runtime_version" {
  description = "Flex Consumption runtime version."
  value       = azurerm_function_app_flex_consumption.this.runtime_version
}

output "service_plan_id" {
  description = "Flex Consumption App Service Plan ID used by the Function App."
  value       = azurerm_function_app_flex_consumption.this.service_plan_id
}

output "storage_container_endpoint" {
  description = "Deployment storage container endpoint used by the Function App."
  value       = azurerm_function_app_flex_consumption.this.storage_container_endpoint
}

output "storage_authentication_type" {
  description = "Storage authentication type used by the Function App."
  value       = azurerm_function_app_flex_consumption.this.storage_authentication_type
}

output "instance_memory_in_mb" {
  description = "Configured memory per Flex Consumption instance."
  value       = azurerm_function_app_flex_consumption.this.instance_memory_in_mb
}

output "maximum_instance_count" {
  description = "Configured maximum Flex Consumption instance count."
  value       = azurerm_function_app_flex_consumption.this.maximum_instance_count
}

output "http_concurrency" {
  description = "Configured HTTP concurrency per Flex Consumption instance."
  value       = azurerm_function_app_flex_consumption.this.http_concurrency
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_function_app_flex_consumption.this.public_network_access_enabled
}

output "identity_principal_id" {
  description = "Principal ID of the managed identity when configured."
  value       = try(azurerm_function_app_flex_consumption.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "Tenant ID of the managed identity when configured."
  value       = try(azurerm_function_app_flex_consumption.this.identity[0].tenant_id, null)
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses for the Function App."
  value       = try(azurerm_function_app_flex_consumption.this.outbound_ip_address_list, [])
}

output "possible_outbound_ip_addresses" {
  description = "Possible outbound IP addresses for the Function App."
  value       = try(azurerm_function_app_flex_consumption.this.possible_outbound_ip_address_list, [])
}

output "tags" {
  description = "Effective tags applied to the Function App."
  value       = local.tags
}
