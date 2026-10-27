output "registry_id" {
  description = "Resource ID of the registry."
  value       = module.acr.id
}

output "login_server" {
  description = "Registry login server."
  value       = module.acr.login_server
}

output "private_endpoint_ip_address" {
  description = "Private IP address assigned to the registry private endpoint."
  value       = module.acr.private_endpoint_ip_address
}
