output "id" {
  description = "Private Endpoint ID."
  value       = azurerm_private_endpoint.this.id
}

output "name" {
  description = "Private Endpoint name."
  value       = azurerm_private_endpoint.this.name
}

output "resource_group_name" {
  description = "Resource group containing the Private Endpoint."
  value       = azurerm_private_endpoint.this.resource_group_name
}

output "subnet_id" {
  description = "Resolved subnet ID used by the Private Endpoint."
  value       = local.subnet_id
}

output "network_interface_id" {
  description = "Private Endpoint network interface ID."
  value       = azurerm_private_endpoint.this.network_interface[0].id
}

output "private_service_connection" {
  description = "Private service connection details."
  value       = azurerm_private_endpoint.this.private_service_connection
}

output "private_dns_zone_ids" {
  description = "Resolved Private DNS zone IDs associated with the Private Endpoint."
  value       = local.private_dns_zone_ids
}

output "custom_dns_configs" {
  description = "Custom DNS configurations reported by Azure."
  value       = azurerm_private_endpoint.this.custom_dns_configs
}

output "tags" {
  description = "Effective tags applied to the Private Endpoint."
  value       = local.tags
}
