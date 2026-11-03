output "policy_definition_id" {
  description = "The custom policy definition ID."
  value       = azurerm_policy_definition.this.id
}

output "policy_definition_name" {
  description = "The custom policy definition name."
  value       = azurerm_policy_definition.this.name
}

output "assignment_id" {
  description = "The assignment resource ID, if created."
  value = try(azurerm_management_group_policy_assignment.this[0].id, null) != null ? azurerm_management_group_policy_assignment.this[0].id : (
    try(azurerm_subscription_policy_assignment.this[0].id, null) != null ? azurerm_subscription_policy_assignment.this[0].id : try(azurerm_resource_group_policy_assignment.this[0].id, null)
  )
}

output "assignment_scope_kind" {
  description = "Resolved assignment scope kind."
  value       = local.assignment_scope_kind
}

output "assignment_identity_principal_id" {
  description = "System-assigned identity principal ID for the assignment, if configured."
  value = try(
    azurerm_management_group_policy_assignment.this[0].identity[0].principal_id,
    azurerm_subscription_policy_assignment.this[0].identity[0].principal_id,
    azurerm_resource_group_policy_assignment.this[0].identity[0].principal_id,
    null
  )
}
