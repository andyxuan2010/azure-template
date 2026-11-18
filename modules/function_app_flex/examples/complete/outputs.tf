output "function_app_id" {
  description = "Flex Consumption Function App resource ID."
  value       = module.functionappflex.id
}

output "function_app_name" {
  description = "Flex Consumption Function App name."
  value       = module.functionappflex.name
}

output "default_hostname" {
  description = "Default Function App hostname."
  value       = module.functionappflex.default_hostname
}

output "identity_principal_id" {
  description = "System-assigned managed identity principal ID."
  value       = module.functionappflex.identity_principal_id
}
