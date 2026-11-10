output "a_record_ids" {
  description = "A record IDs."
  value       = module.private_dns.a_record_ids
}

output "aaaa_record_ids" {
  description = "AAAA record IDs."
  value       = module.private_dns.aaaa_record_ids
}

output "cname_record_ids" {
  description = "CNAME record IDs."
  value       = module.private_dns.cname_record_ids
}

output "txt_record_ids" {
  description = "TXT record IDs."
  value       = module.private_dns.txt_record_ids
}
