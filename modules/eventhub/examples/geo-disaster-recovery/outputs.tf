output "primary_namespace_id" {
  description = "Primary Event Hubs namespace ID."
  value       = module.primary_event_hubs.id
}

output "disaster_recovery_config_id" {
  description = "Geo-Disaster Recovery configuration ID."
  value       = module.primary_event_hubs.disaster_recovery_config_id
}
