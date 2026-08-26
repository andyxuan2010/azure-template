output "zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = module.private_dns.zone_ids
}

output "vnet_link_ids" {
  description = "VNet link IDs keyed by zone and link name."
  value       = module.private_dns.vnet_link_ids
}

output "merged_tags" {
  description = "Effective module tag baseline."
  value       = module.private_dns.merged_tags
}
