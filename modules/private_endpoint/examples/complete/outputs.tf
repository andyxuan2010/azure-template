output "id" {
  description = "Private Endpoint ID."
  value       = module.private_endpoint.id
}

output "network_interface_id" {
  description = "Private Endpoint network interface ID."
  value       = module.private_endpoint.network_interface_id
}

output "private_service_connection" {
  description = "Private service connection details."
  value       = module.private_endpoint.private_service_connection
}
