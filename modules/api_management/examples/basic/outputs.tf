output "api_management_id" {
  description = "API Management service resource ID."
  value       = module.api_management.id
}

output "gateway_url" {
  description = "API gateway URL."
  value       = module.api_management.gateway_url
}
