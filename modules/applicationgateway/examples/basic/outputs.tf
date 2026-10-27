output "application_gateway_id" {
  description = "Resource ID of the Application Gateway."
  value       = module.application_gateway.id
}

output "public_ip_address" {
  description = "Public IP address assigned to the gateway."
  value       = module.application_gateway.public_ip_address
}
