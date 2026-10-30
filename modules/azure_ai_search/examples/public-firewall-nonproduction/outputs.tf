output "search_endpoint" {
  description = "Public Search endpoint restricted by the configured firewall."
  value       = module.search.endpoint
}

output "public_network_access_enabled" {
  description = "Confirms that this scenario deliberately enables public access."
  value       = module.search.public_network_access_enabled
}
