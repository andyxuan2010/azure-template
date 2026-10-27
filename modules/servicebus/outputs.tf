output "id" {
  description = "The Service Bus namespace resource ID."
  value       = azurerm_servicebus_namespace.this.id
}

output "name" {
  description = "The Service Bus namespace name."
  value       = azurerm_servicebus_namespace.this.name
}

output "endpoint" {
  description = "The Service Bus namespace endpoint."
  value       = azurerm_servicebus_namespace.this.endpoint
}

output "queue_ids" {
  description = "Queue resource IDs keyed by queue name."
  value       = { for k, v in azurerm_servicebus_queue.this : k => v.id }
}

output "topic_ids" {
  description = "Topic resource IDs keyed by topic name."
  value       = { for k, v in azurerm_servicebus_topic.this : k => v.id }
}

output "subscription_ids" {
  description = "Subscription resource IDs keyed by subscription name."
  value       = { for k, v in azurerm_servicebus_subscription.this : k => v.id }
}

output "authorization_rule_ids" {
  description = "Namespace authorization rule IDs keyed by rule name."
  value       = { for k, v in azurerm_servicebus_namespace_authorization_rule.this : k => v.id }
}

output "app_admin_group_role_assignment_ids" {
  description = "Contributor role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_admin_group : k => v.id }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs keyed by principal ID."
  value       = { for k, v in azurerm_role_assignment.app_user_group : k => v.id }
}

output "private_endpoint_id" {
  description = "Private endpoint ID when private endpoint is enabled."
  value       = try(azurerm_private_endpoint.this[0].id, null)
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID when diagnostics are enabled."
  value       = try(azurerm_monitor_diagnostic_setting.this[0].id, null)
}

output "tags" {
  description = "Effective tags applied to the Service Bus namespace."
  value       = azurerm_servicebus_namespace.this.tags
}

output "merged_tags" {
  description = "Final merged tags applied to the namespace."
  value       = local.merged_tags
}
