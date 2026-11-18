output "account_id" {
  description = "Resource ID of the Azure OpenAI account."
  value       = module.openai.id
}

output "identity" {
  description = "System-assigned and user-assigned identity details."
  value       = module.openai.identity
}
