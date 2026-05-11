# Core Resource Information
output "id" {
  description = "The ID of the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.id
}

output "name" {
  description = "The name of the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.name
}

output "resource_group_name" {
  description = "The name of the resource group containing the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.resource_group_name
}

output "location" {
  description = "The location of the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.location
}

# Identity Information
output "identity" {
  description = "The identity block of the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.identity
}

output "principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity (null when identity is disabled)."
  value       = try(azurerm_automation_account.azure_automationaccount.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The Tenant ID of the System Assigned Managed Identity (null when identity is disabled)."
  value       = try(azurerm_automation_account.azure_automationaccount.identity[0].tenant_id, null)
}

# Configuration Information
output "sku_name" {
  description = "The SKU name of the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.sku_name
}

output "local_authentication_enabled" {
  description = "Whether local authentication is enabled for the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.local_authentication_enabled
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled for the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.public_network_access_enabled
}

# Private Endpoint Information
output "private_endpoint_id" {
  description = "The ID of a private endpoint when exactly one exists, otherwise the legacy/default endpoint if present."
  value = length(azurerm_private_endpoint.pep) == 1 ? values(azurerm_private_endpoint.pep)[0].id : (
    try(azurerm_private_endpoint.pep["legacy"].id, try(azurerm_private_endpoint.pep["webhook"].id, try(azurerm_private_endpoint.pep["hrw"].id, null)))
  )
}

output "private_endpoint_name" {
  description = "The name of a private endpoint when exactly one exists, otherwise the legacy/default endpoint if present."
  value = length(azurerm_private_endpoint.pep) == 1 ? values(azurerm_private_endpoint.pep)[0].name : (
    try(azurerm_private_endpoint.pep["legacy"].name, try(azurerm_private_endpoint.pep["webhook"].name, try(azurerm_private_endpoint.pep["hrw"].name, null)))
  )
}

output "private_endpoint_ids" {
  description = "Map of private endpoint IDs keyed by endpoint selector."
  value       = { for k, v in azurerm_private_endpoint.pep : k => v.id }
}

output "private_endpoint_names" {
  description = "Map of private endpoint names keyed by endpoint selector."
  value       = { for k, v in azurerm_private_endpoint.pep : k => v.name }
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting (if created)."
  value       = length(azurerm_monitor_diagnostic_setting.automation_account) > 0 ? azurerm_monitor_diagnostic_setting.automation_account[0].id : null
}

output "managed_identity_role_assignment_ids" {
  description = "Map of managed identity role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.managed_identity : k => v.id }
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

# Tags
output "tags" {
  description = "The tags assigned to the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.tags
}
