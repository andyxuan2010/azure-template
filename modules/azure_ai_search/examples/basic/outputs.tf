output "search_service_id" {
  description = "Azure AI Search resource ID."
  value       = module.search.id
}

output "endpoint" {
  description = "Azure AI Search endpoint."
  value       = module.search.endpoint
}

output "principal_id" {
  description = "System-assigned identity principal ID."
  value       = module.search.principal_id
}
