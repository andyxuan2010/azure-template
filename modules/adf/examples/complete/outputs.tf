output "data_factory_id" {
  description = "Resource ID of Data Factory."
  value       = module.adf.id
}

output "private_endpoint_id" {
  description = "Resource ID of the ADF control-plane private endpoint."
  value       = module.adf.private_endpoint_id
}

output "managed_private_endpoint_ids" {
  description = "Managed private endpoint IDs keyed by their input names."
  value       = module.adf.managed_private_endpoint_ids
}
