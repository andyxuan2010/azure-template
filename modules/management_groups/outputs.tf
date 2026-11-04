output "id" {
  description = "The resource ID of the management group."
  value       = azurerm_management_group.this.id
}

output "name" {
  description = "The management group ID."
  value       = azurerm_management_group.this.name
}

output "display_name" {
  description = "The management group display name."
  value       = azurerm_management_group.this.display_name
}

output "parent_management_group_id" {
  description = "The parent management group resource ID, if configured."
  value       = try(azurerm_management_group.this.parent_management_group_id, null)
}

output "subscription_ids" {
  description = "Subscription IDs associated to the management group."
  value       = azurerm_management_group.this.subscription_ids
}

output "tags" {
  description = "Documentation tags emitted by this module."
  value       = local.merged_tags
}

output "merged_tags" {
  description = "Final merged tags emitted by this module for consistency with other modules."
  value       = local.merged_tags
}
