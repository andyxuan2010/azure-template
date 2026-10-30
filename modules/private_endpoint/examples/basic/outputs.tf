output "id" {
  description = "Private Endpoint ID."
  value       = module.private_endpoint.id
}

output "name" {
  description = "Private Endpoint name."
  value       = module.private_endpoint.name
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs associated with the endpoint."
  value       = module.private_endpoint.private_dns_zone_ids
}
