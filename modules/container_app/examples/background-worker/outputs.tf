output "worker_id" {
  description = "Background worker Container App ID."
  value       = module.worker.id
}

output "outbound_ip_addresses" {
  description = "Outbound IP addresses reported for the worker."
  value       = module.worker.outbound_ip_addresses
}
