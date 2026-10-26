output "namespace_id" {
  description = "Service Bus namespace ID."
  value       = module.servicebus.id
}

output "queue_ids" {
  description = "Queue IDs keyed by queue name."
  value       = module.servicebus.queue_ids
}
