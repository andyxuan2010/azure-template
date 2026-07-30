output "id" {
  description = "Azure Firewall ID."
  value       = azurerm_firewall.this.id
}

output "name" {
  description = "Azure Firewall name."
  value       = azurerm_firewall.this.name
}

output "resource_group_name" {
  description = "Resource group where the Azure Firewall is deployed."
  value       = azurerm_firewall.this.resource_group_name
}

output "location" {
  description = "Azure region where the Azure Firewall is deployed."
  value       = azurerm_firewall.this.location
}

output "location_code" {
  description = "The short location code used by generated names."
  value       = local.location_code_resolved
}

output "app_env" {
  description = "Deployment environment used for tags and generated names."
  value       = var.app_env
}

output "sku_name" {
  description = "Azure Firewall SKU name."
  value       = azurerm_firewall.this.sku_name
}

output "sku_tier" {
  description = "Azure Firewall SKU tier."
  value       = azurerm_firewall.this.sku_tier
}

output "private_ip_address" {
  description = "Primary Azure Firewall private IP address."
  value       = try(azurerm_firewall.this.ip_configuration[0].private_ip_address, try(azurerm_firewall.this.virtual_hub[0].private_ip_address, null))
}

output "management_private_ip_address" {
  description = "Azure Firewall management private IP address when forced tunneling is configured."
  value       = try(azurerm_firewall.this.management_ip_configuration[0].private_ip_address, null)
}

output "public_ip_id" {
  description = "First created or supplied firewall public IP ID."
  value       = try(local.firewall_public_ip_ids[0], null)
}

output "public_ip_ids" {
  description = "Firewall public IP IDs attached to VNet-deployed firewalls."
  value       = local.firewall_public_ip_ids
}

output "public_ip_count" {
  description = "Number of firewall public IP IDs planned or supplied."
  value       = length(local.public_ip_names) + length(var.public_ip_ids)
}

output "public_ip_addresses" {
  description = "Created firewall public IP addresses keyed by public IP index."
  value       = { for k, v in azurerm_public_ip.this : k => v.ip_address }
}

output "management_public_ip_id" {
  description = "Management public IP ID when forced tunneling is configured."
  value       = local.management_public_ip_id != "" ? local.management_public_ip_id : null
}

output "management_ip_configuration_enabled" {
  description = "Whether a management IP configuration is planned for forced tunneling."
  value       = local.management_ip_configuration_set
}

output "management_public_ip_address" {
  description = "Created management public IP address when the module creates it."
  value       = try(azurerm_public_ip.management[0].ip_address, null)
}

output "firewall_policy_id" {
  description = "Firewall Policy ID attached to the firewall."
  value       = local.firewall_policy_id != "" ? local.firewall_policy_id : null
}

output "firewall_policy_name" {
  description = "Firewall Policy name when created by the module."
  value       = try(azurerm_firewall_policy.this[0].name, null)
}

output "firewall_policy_sku" {
  description = "Effective Firewall Policy SKU."
  value       = local.firewall_policy_sku
}

output "rule_collection_group_id" {
  description = "First Firewall Policy rule collection group ID when created."
  value       = try(values(azurerm_firewall_policy_rule_collection_group.this)[0].id, null)
}

output "rule_collection_group_ids" {
  description = "Firewall Policy rule collection group IDs keyed by group key."
  value       = { for k, v in azurerm_firewall_policy_rule_collection_group.this : k => v.id }
}

output "rule_collection_group_count" {
  description = "Number of Firewall Policy rule collection groups planned by this module."
  value       = length(local.rule_collection_groups)
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
  description = "Effective tags applied to the Azure Firewall."
  value       = azurerm_firewall.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to firewall resources."
  value       = local.merged_tags
}
