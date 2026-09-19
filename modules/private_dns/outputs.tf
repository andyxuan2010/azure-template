output "zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.id }
}

output "vnet_link_ids" {
  description = "Private DNS VNet link IDs keyed by zone/link key."
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.this : k => v.id }
}

output "a_record_ids" {
  description = "Private DNS A record IDs keyed by zone/record key."
  value       = { for k, v in azurerm_private_dns_a_record.this : k => v.id }
}

output "aaaa_record_ids" {
  description = "Private DNS AAAA record IDs keyed by zone/record key."
  value       = { for k, v in azurerm_private_dns_aaaa_record.this : k => v.id }
}

output "cname_record_ids" {
  description = "Private DNS CNAME record IDs keyed by zone/record key."
  value       = { for k, v in azurerm_private_dns_cname_record.this : k => v.id }
}

output "txt_record_ids" {
  description = "Private DNS TXT record IDs keyed by zone/record key."
  value       = { for k, v in azurerm_private_dns_txt_record.this : k => v.id }
}

output "tags" {
  description = "Effective tags applied to private DNS zones keyed by zone name."
  value       = { for k, v in azurerm_private_dns_zone.this : k => v.tags }
}

output "merged_tags" {
  description = "Final merged tags applied to private DNS resources."
  value       = local.merged_tags
}
