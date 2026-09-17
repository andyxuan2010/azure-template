output "namespace_id" {
  description = "Event Hubs namespace resource ID."
  value       = module.event_hubs.id
}

output "eventhub_ids" {
  description = "Event Hub IDs keyed by logical name."
  value       = module.event_hubs.eventhub_ids
}

output "consumer_group_ids" {
  description = "Consumer group IDs keyed by logical name."
  value       = module.event_hubs.consumer_group_ids
}
