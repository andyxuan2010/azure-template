output "policy_definition_id" {
  description = "Custom policy definition ID."
  value       = module.policy.policy_definition_id
}

output "assignment_id" {
  description = "Resource group policy assignment ID."
  value       = module.policy.assignment_id
}

output "assignment_identity_principal_id" {
  description = "Policy assignment system identity principal ID."
  value       = module.policy.assignment_identity_principal_id
}
