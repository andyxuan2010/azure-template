output "data_factory_id" {
  description = "Resource ID of Data Factory."
  value       = module.adf.id
}

output "self_hosted_integration_runtime_id" {
  description = "Resource ID of the self-hosted integration runtime."
  value       = module.adf.self_hosted_integration_runtime_id
}
