output "service_connection_id" {
  description = "Service connection ID for Azure DevOps checks and administration."
  value       = module.example.id
}
output "service_connection_name" {
  description = "Service connection name used in pipeline task inputs."
  value       = module.example.name
}
