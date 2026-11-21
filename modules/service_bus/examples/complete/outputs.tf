output "namespace_id" {
  description = "Service Bus namespace ID."
  value       = module.servicebus.id
}

output "queue_ids" {
  description = "Queue IDs keyed by queue name."
  value       = module.servicebus.queue_ids
}

output "topic_ids" {
  description = "Topic IDs keyed by topic name."
  value       = module.servicebus.topic_ids
}

output "private_endpoint_id" {
  description = "Private Endpoint ID."
  value       = module.servicebus.private_endpoint_id
}

output "diagnostic_setting_id" {
  description = "Diagnostic setting ID."
  value       = module.servicebus.diagnostic_setting_id
}
