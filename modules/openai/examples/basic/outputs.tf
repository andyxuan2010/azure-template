output "account_id" {
  description = "Resource ID of the Azure OpenAI account."
  value       = module.openai.id
}

output "endpoint" {
  description = "Azure OpenAI account endpoint."
  value       = module.openai.endpoint
}

output "identity" {
  description = "Managed identity details for the account."
  value       = module.openai.identity
}
