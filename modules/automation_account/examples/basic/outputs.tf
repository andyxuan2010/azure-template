output "automation_account_id" {
  description = "Resource ID of the Automation Account."
  value       = module.automation.id
}

output "principal_id" {
  description = "Principal ID of the system-assigned managed identity."
  value       = module.automation.principal_id
}

output "public_network_access_enabled" {
  description = "Whether public access is enabled."
  value       = module.automation.public_network_access_enabled
}
