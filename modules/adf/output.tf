# output "resource_group_name" {
#   value = azurerm_resource_group.app.name
#   #value = var.app_rg
# }

# output "azurerm_cognitive_account_name" {
#   value = azurerm_cognitive_account.cognitive-service.name
# }

# # Output the endpoint and private endpoint URL
# output "cognitive-service-endpoint" {
#   value = azurerm_cognitive_account.cognitive-service.endpoint
# }

# output "private_endpoint_url" {
#   value = azurerm_private_endpoint.edp-cognitive.custom_dns_configs[0].fqdn
# }

# output "private_endpoint_private_ips" {
#   value = azurerm_private_endpoint.edp-cognitive.custom_dns_configs[0].ip_addresses
# }


output "id" {
  value       = azurerm_data_factory.this.id
  description = "Data Factory ID"
}

output "name" {
  value       = azurerm_data_factory.this.name
  description = "Data Factory Name"
}

output "identity" {
  value       = azurerm_data_factory.this.identity[*]
  description = "Data Factory Managed Identity"
}

output "default_integration_runtime_name" {
  value       = azurerm_data_factory_integration_runtime_azure.auto_resolve.name
  description = "Data Factory Default Integration Runtime Name"
}

output "self_hosted_integration_runtime_key" {
  value       = try(azurerm_data_factory_integration_runtime_self_hosted.this[0].primary_authorization_key, null)
  description = "Self hosted integration runtime primary authorization key"
}

output "merged_tags" {
  description = "Final merged tags applied to resources"
  value       = local.merged_tags
}

output "diagnostics_enabled" {
  description = "True when log analytics workspace mapping provided"
  value       = local.diagnostics_enabled
}

output "app_admin_group_role_assignment_ids" {
  description = "Map of Contributor role assignment IDs keyed by app_admin_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Map of Reader role assignment IDs keyed by app_user_group principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

# output "role_assignments" {
#   value = azurerm_role_assignment.vm2adf
#}
