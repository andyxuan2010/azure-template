output "ai_services_id" {
  description = "Azure AI Services account ID."
  value       = module.ai_services.id
}

output "endpoint" {
  description = "Azure AI Services endpoint."
  value       = module.ai_services.endpoint
}

output "principal_id" {
  description = "System-assigned identity principal ID."
  value       = module.ai_services.principal_id
}
