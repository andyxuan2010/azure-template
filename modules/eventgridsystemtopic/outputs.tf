output "id" {
  description = "The resource ID of the Event Grid System Topic."
  value       = azurerm_eventgrid_system_topic.this.id
}

output "name" {
  description = "The Event Grid System Topic name."
  value       = azurerm_eventgrid_system_topic.this.name
}

output "resource_group_name" {
  description = "The resource group containing the Event Grid System Topic."
  value       = azurerm_eventgrid_system_topic.this.resource_group_name
}

output "location" {
  description = "The Azure region of the Event Grid System Topic."
  value       = azurerm_eventgrid_system_topic.this.location
}

output "topic_type" {
  description = "The Event Grid topic type associated with the source resource."
  value       = azurerm_eventgrid_system_topic.this.topic_type
}

output "source_resource_id" {
  description = "The source Azure resource ID associated with the system topic."
  value       = azurerm_eventgrid_system_topic.this.source_resource_id
}

output "metric_resource_id" {
  description = "The metric resource ID returned by Azure, if available."
  value       = azurerm_eventgrid_system_topic.this.metric_resource_id
}

output "metric_arm_resource_id" {
  description = "The metric Azure Resource Manager resource ID returned by Azure, if available."
  value       = azurerm_eventgrid_system_topic.this.metric_arm_resource_id
}

output "identity_principal_id" {
  description = "The principal ID of the managed identity, if one is configured."
  value       = try(azurerm_eventgrid_system_topic.this.identity[0].principal_id, null)
}

output "identity_tenant_id" {
  description = "The tenant ID of the managed identity, if one is configured."
  value       = try(azurerm_eventgrid_system_topic.this.identity[0].tenant_id, null)
}

output "tags" {
  description = "The effective tags applied to the Event Grid System Topic."
  value       = local.tags
}
