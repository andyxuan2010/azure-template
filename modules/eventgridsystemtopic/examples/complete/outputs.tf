output "event_grid_system_topic_id" {
  description = "Event Grid System Topic resource ID."
  value       = module.eventgridsystemtopic.id
}

output "event_grid_system_topic_name" {
  description = "Event Grid System Topic name."
  value       = module.eventgridsystemtopic.name
}

output "identity_principal_id" {
  description = "System-assigned managed identity principal ID."
  value       = module.eventgridsystemtopic.identity_principal_id
}
