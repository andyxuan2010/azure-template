output "load_balancer_id" {
  description = "Resource ID of the Load Balancer."
  value       = module.load_balancer.id
}

output "backend_address_pool_ids" {
  description = "Backend pool IDs keyed by name."
  value       = module.load_balancer.backend_address_pool_ids
}

output "rule_ids" {
  description = "Load-balancing rule IDs keyed by name."
  value       = module.load_balancer.rule_ids
}
