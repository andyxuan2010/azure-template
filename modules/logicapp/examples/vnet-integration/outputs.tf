output "logic_app_id" {
  description = "Resource ID of the Logic App Standard host."
  value       = module.logic_app.id
}

output "identity_principal_id" {
  description = "Principal ID of the system-assigned identity."
  value       = module.logic_app.identity_principal_id
}
