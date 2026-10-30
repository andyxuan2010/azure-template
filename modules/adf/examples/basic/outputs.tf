output "data_factory_id" {
  description = "Resource ID of Data Factory."
  value       = module.adf.id
}

output "data_factory_principal_id" {
  description = "Principal ID of the Data Factory managed identity."
  value       = module.adf.principal_id
}
