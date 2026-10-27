output "virtual_network_id" {
  description = "VNet resource ID."
  value       = module.vnet.id
}

output "app_service_subnet_id" {
  description = "Delegated App Service subnet resource ID."
  value       = module.vnet.subnet_ids["app-service"]
}
