output "logic_app_id" {
  description = "Resource ID of the Logic App Standard host."
  value       = module.logic_app.id
}

output "private_endpoint_id" {
  description = "Resource ID of the Logic App private endpoint."
  value       = module.logic_app.private_endpoint_id
}

output "diagnostic_setting_id" {
  description = "Resource ID of the Logic App diagnostic setting."
  value       = module.logic_app.diagnostic_setting_id
}
