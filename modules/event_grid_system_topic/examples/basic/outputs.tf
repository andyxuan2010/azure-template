output "event_grid_system_topic_id" {
  description = "Event Grid System Topic resource ID."
  value       = module.eventgridsystemtopic.id
}

output "event_grid_system_topic_name" {
  description = "Event Grid System Topic name."
  value       = module.eventgridsystemtopic.name
}

output "source_resource_id" {
  description = "Event source resource ID."
  value       = module.eventgridsystemtopic.source_resource_id
}
