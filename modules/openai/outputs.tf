output "id" {
  description = "The Azure OpenAI account resource ID."
  value       = azurerm_cognitive_account.this.id
}

output "name" {
  description = "The Azure OpenAI account name."
  value       = azurerm_cognitive_account.this.name
}

output "endpoint" {
  description = "The Azure OpenAI endpoint."
  value       = azurerm_cognitive_account.this.endpoint
}

output "primary_access_key" {
  description = "The primary access key."
  value       = azurerm_cognitive_account.this.primary_access_key
  sensitive   = true
}

output "secondary_access_key" {
  description = "The secondary access key."
  value       = azurerm_cognitive_account.this.secondary_access_key
  sensitive   = true
}

output "deployment_ids" {
  description = "Deployment resource IDs keyed by deployment name."
  value       = { for k, v in azurerm_cognitive_deployment.this : k => v.id }
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
  description = "Effective tags applied to the Azure OpenAI account."
  value       = azurerm_cognitive_account.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the Azure OpenAI account."
  value       = local.merged_tags
}
