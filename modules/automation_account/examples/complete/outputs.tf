output "automation_account_id" {
  description = "Resource ID of the Automation Account."
  value       = module.automation.id
}

output "principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = module.automation.principal_id
}

output "private_endpoint_ids" {
  description = "Private endpoint IDs keyed by Automation subresource."
  value       = module.automation.private_endpoint_ids
}

output "diagnostic_setting_id" {
  description = "Resource ID of the diagnostic setting."
  value       = module.automation.diagnostic_setting_id
}
