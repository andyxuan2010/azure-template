output "id" {
  description = "The Event Hub namespace resource ID."
  value       = azurerm_eventhub_namespace.this.id
}

output "name" {
  description = "The Event Hub namespace name."
  value       = azurerm_eventhub_namespace.this.name
}

output "default_primary_connection_string" {
  description = "The default primary connection string for the Event Hub namespace."
  value       = azurerm_eventhub_namespace.this.default_primary_connection_string
  sensitive   = true
}

output "default_secondary_connection_string" {
  description = "The default secondary connection string for the Event Hub namespace."
  value       = azurerm_eventhub_namespace.this.default_secondary_connection_string
  sensitive   = true
}

output "eventhub_ids" {
  description = "Event Hub resource IDs keyed by Event Hub name."
  value       = { for k, v in azurerm_eventhub.this : k => v.id }
}

output "authorization_rule_ids" {
  description = "Namespace authorization rule IDs keyed by rule name."
  value       = { for k, v in azurerm_eventhub_namespace_authorization_rule.this : k => v.id }
}

output "private_endpoint_id" {
  description = "Private endpoint ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "app_admin_group_role_assignment_ids" {
  description = "Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "tags" {
  description = "Effective tags applied to the Event Hub namespace."
  value       = azurerm_eventhub_namespace.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the namespace."
  value       = local.merged_tags
}
