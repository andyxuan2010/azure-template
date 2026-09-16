output "topic_ids" {
  description = "Topic IDs keyed by topic name."
  value       = module.servicebus.topic_ids
}

output "subscription_ids" {
  description = "Subscription IDs keyed by subscription name."
  value       = module.servicebus.subscription_ids
}
