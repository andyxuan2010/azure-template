output "account_id" {
  description = "Resource ID of the Azure OpenAI account."
  value       = module.openai.id
}

output "endpoint" {
  description = "Private-DNS-backed Azure OpenAI endpoint."
  value       = module.openai.endpoint
}

output "deployment_details" {
  description = "Deployment details keyed by Terraform deployment name."
  value       = module.openai.deployment_details
}

output "private_endpoint_id" {
  description = "Resource ID of the Azure OpenAI private endpoint."
  value       = module.openai.private_endpoint_id
}
