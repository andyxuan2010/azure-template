output "policy_definition_id" {
  description = "Management group-scoped custom policy definition ID."
  value       = module.policy.policy_definition_id
}

output "assignment_id" {
  description = "Management group policy assignment ID."
  value       = module.policy.assignment_id
}
