output "zone_ids" {
  description = "Private DNS zone IDs keyed by zone name."
  value       = module.private_dns.zone_ids
}

output "a_record_ids" {
  description = "A record IDs keyed by zone and record name."
  value       = module.private_dns.a_record_ids
}
