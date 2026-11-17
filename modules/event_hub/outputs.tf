output "id" {
  description = "The Event Hubs namespace resource ID."
  value       = azurerm_eventhub_namespace.this.id
}

output "name" {
  description = "The Event Hubs namespace name."
  value       = azurerm_eventhub_namespace.this.name
}

output "resource_group_name" {
  description = "The resource group name where the Event Hubs namespace is deployed."
  value       = azurerm_eventhub_namespace.this.resource_group_name
}

output "location" {
  description = "The Azure region where the Event Hubs namespace is deployed."
  value       = azurerm_eventhub_namespace.this.location
}

output "location_code" {
  description = "The short location code used by generated names."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "The deployment environment used for tags and generated names."
  value       = var.app_env
}

output "sku" {
  description = "The Event Hubs namespace SKU."
  value       = azurerm_eventhub_namespace.this.sku
}

output "capacity" {
  description = "The Event Hubs namespace capacity."
  value       = azurerm_eventhub_namespace.this.capacity
}

output "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  value       = azurerm_eventhub_namespace.this.public_network_access_enabled
}

output "local_authentication_enabled" {
  description = "Whether SAS/local authentication is enabled."
  value       = azurerm_eventhub_namespace.this.local_authentication_enabled
}

output "identity" {
  description = "Managed identity details for the Event Hubs namespace."
  value       = try(azurerm_eventhub_namespace.this.identity[0], null)
}

output "identity_type" {
  description = "The managed identity type enabled on the Event Hubs namespace."
  value       = local.identity_type
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_eventhub_namespace.this.identity[0].principal_id, null)
}

output "tenant_id" {
  description = "The tenant ID of the system-assigned managed identity, when enabled."
  value       = try(azurerm_eventhub_namespace.this.identity[0].tenant_id, null)
}

output "default_primary_connection_string" {
  description = "The default primary connection string for the Event Hubs namespace when local authentication is enabled."
  value       = try(azurerm_eventhub_namespace.this.default_primary_connection_string, null)
  sensitive   = true
}

output "default_secondary_connection_string" {
  description = "The default secondary connection string for the Event Hubs namespace when local authentication is enabled."
  value       = try(azurerm_eventhub_namespace.this.default_secondary_connection_string, null)
  sensitive   = true
}

output "eventhub_ids" {
  description = "Event Hub resource IDs keyed by input key."
  value       = { for k, v in azurerm_eventhub.this : k => v.id }
}

output "eventhub_names" {
  description = "Event Hub names keyed by input key."
  value       = { for k, v in azurerm_eventhub.this : k => v.name }
}

output "eventhub_partition_ids" {
  description = "Event Hub partition IDs keyed by input key."
  value       = { for k, v in azurerm_eventhub.this : k => v.partition_ids }
}

output "consumer_group_ids" {
  description = "Consumer group IDs keyed by <eventhub-key>.<consumer-group-key>."
  value       = { for k, v in azurerm_eventhub_consumer_group.this : k => v.id }
}

output "namespace_authorization_rule_ids" {
  description = "Namespace authorization rule IDs keyed by rule name."
  value       = { for k, v in azurerm_eventhub_namespace_authorization_rule.this : k => v.id }
}

output "authorization_rule_ids" {
  description = "Backward-compatible alias for namespace authorization rule IDs keyed by rule name."
  value       = { for k, v in azurerm_eventhub_namespace_authorization_rule.this : k => v.id }
}

output "eventhub_authorization_rule_ids" {
  description = "Event Hub authorization rule IDs keyed by <eventhub-key>.<rule-key>."
  value       = { for k, v in azurerm_eventhub_authorization_rule.this : k => v.id }
}

output "namespace_authorization_rule_primary_connection_strings" {
  description = "Namespace authorization rule primary connection strings keyed by rule name."
  value       = { for k, v in azurerm_eventhub_namespace_authorization_rule.this : k => v.primary_connection_string }
  sensitive   = true
}

output "eventhub_authorization_rule_primary_connection_strings" {
  description = "Event Hub authorization rule primary connection strings keyed by <eventhub-key>.<rule-key>."
  value       = { for k, v in azurerm_eventhub_authorization_rule.this : k => v.primary_connection_string }
  sensitive   = true
}

output "schema_group_ids" {
  description = "Schema group IDs keyed by input key."
  value       = { for k, v in azurerm_eventhub_namespace_schema_group.this : k => v.id }
}

output "customer_managed_key_id" {
  description = "Customer-managed key resource ID when configured."
  value       = try(azurerm_eventhub_namespace_customer_managed_key.this[0].id, null)
}

output "disaster_recovery_config_id" {
  description = "Geo-disaster recovery config ID when configured."
  value       = try(azurerm_eventhub_namespace_disaster_recovery_config.this[0].id, null)
}

output "private_endpoint_id" {
  description = "Private endpoint ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "private_endpoint_name" {
  description = "Private endpoint name when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].name, null)
}

output "private_endpoint_fqdns" {
  description = "Private endpoint FQDNs when private endpoint is enabled."
  value       = try([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.fqdn], null)
}

output "private_endpoint_ip_addresses" {
  description = "Private endpoint IP addresses when private endpoint is enabled."
  value       = try(flatten([for config in azurerm_private_endpoint.this[0].custom_dns_configs : config.ip_addresses]), null)
}

output "diagnostics_enabled" {
  description = "Boolean flag indicating whether diagnostics are enabled."
  value       = local.diagnostics_enabled
}

output "diagnostic_setting_name" {
  description = "Diagnostic setting name when diagnostics are enabled."
  value       = local.diagnostics_enabled ? local.diagnostic_setting_name : null
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
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
  description = "Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "role_assignment_ids" {
  description = "Map of additional role assignment IDs keyed by assignment name."
  value       = { for k, v in azurerm_role_assignment.this : k => v.id }
}

output "role_assignment_count" {
  description = "Total number of role assignments created by this module."
  value = (
    length(azurerm_role_assignment.app_admin_group) +
    length(azurerm_role_assignment.app_user_group) +
    length(azurerm_role_assignment.this)
  )
}

output "tags" {
  description = "Effective tags applied to the Event Hubs namespace."
  value       = azurerm_eventhub_namespace.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the Event Hubs namespace."
  value       = local.merged_tags
}
