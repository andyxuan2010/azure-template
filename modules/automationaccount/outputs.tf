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

output "location_code" {
  description = "The short location code used by generated names."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "The deployment environment used for tags and generated names."
  value       = var.app_env
}

output "identity" {
  description = "The identity block of the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.identity
}

output "identity_type" {
  description = "The managed identity type enabled on the Automation Account."
  value       = local.identity_type
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_automation_account.azure_automationaccount.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_automation_account.azure_automationaccount.identity[0].tenant_id, null)
}

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

output "dsc_server_endpoint" {
  description = "The DSC server endpoint associated with the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.dsc_server_endpoint
}

output "hybrid_service_url" {
  description = "The hybrid service URL used for hybrid worker onboarding."
  value       = azurerm_automation_account.azure_automationaccount.hybrid_service_url
}

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

output "diagnostics_enabled" {
  description = "Whether the module creates a diagnostic setting."
  value       = local.diagnostics_enabled
}

output "diagnostic_setting_name" {
  description = "The diagnostic setting name when diagnostics are enabled."
  value       = local.diagnostics_enabled ? local.diagnostic_setting_name : null
}

output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting, if created."
  value       = length(azurerm_monitor_diagnostic_setting.automation_account) > 0 ? azurerm_monitor_diagnostic_setting.automation_account[0].id : null
}

output "runbook_ids" {
  description = "Map of Automation Runbook IDs keyed by runbook key."
  value       = { for k, v in azurerm_automation_runbook.this : k => v.id }
}

output "runbook_names" {
  description = "Map of Automation Runbook names keyed by runbook key."
  value       = { for k, v in azurerm_automation_runbook.this : k => v.name }
}

output "schedule_ids" {
  description = "Map of Automation Schedule IDs keyed by schedule key."
  value       = { for k, v in azurerm_automation_schedule.this : k => v.id }
}

output "schedule_names" {
  description = "Map of Automation Schedule names keyed by schedule key."
  value       = { for k, v in azurerm_automation_schedule.this : k => v.name }
}

output "job_schedule_ids" {
  description = "Map of Automation Job Schedule IDs keyed by job schedule key."
  value       = { for k, v in azurerm_automation_job_schedule.this : k => v.id }
}

output "automation_variable_ids" {
  description = "Automation variable IDs grouped by variable type."
  value = {
    string   = { for k, v in azurerm_automation_variable_string.this : k => v.id }
    bool     = { for k, v in azurerm_automation_variable_bool.this : k => v.id }
    int      = { for k, v in azurerm_automation_variable_int.this : k => v.id }
    datetime = { for k, v in azurerm_automation_variable_datetime.this : k => v.id }
    object   = { for k, v in azurerm_automation_variable_object.this : k => v.id }
  }
}

output "managed_identity_role_assignment_ids" {
  description = "Map of managed identity role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.managed_identity : k => v.id }
}

output "app_admin_group_principal_ids" {
  description = "Map of resolved app admin group principal IDs."
  value       = local.app_admin_group_principal_ids
}

output "app_user_group_principal_ids" {
  description = "Map of resolved app user group principal IDs."
  value       = local.app_user_group_principal_ids
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
  description = "Map of additional role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments created by this module."
  value = (
    length(azurerm_role_assignment.managed_identity) +
    length(azurerm_role_assignment.app_admin_group) +
    length(azurerm_role_assignment.app_user_group) +
    length(azurerm_role_assignment.this)
  )
}

output "tags" {
  description = "The tags assigned to the Automation Account."
  value       = azurerm_automation_account.azure_automationaccount.tags
}
