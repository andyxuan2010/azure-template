output "id" {
  description = "The ID of the Load Balancer."
  value       = azurerm_lb.this.id
}

output "name" {
  description = "The Name of the Load Balancer."
  value       = azurerm_lb.this.name
}

output "frontend_ip_configurations" {
  description = "A list of frontend IP configuration objects."
  value       = azurerm_lb.this.frontend_ip_configuration
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool IDs keyed by name."
  value       = { for name, pool in azurerm_lb_backend_address_pool.this : name => pool.id }
}

output "probe_ids" {
  description = "Map of probe IDs keyed by name."
  value       = { for name, probe in azurerm_lb_probe.this : name => probe.id }
}

output "rule_ids" {
  description = "Map of rule IDs keyed by name."
  value       = { for name, rule in azurerm_lb_rule.this : name => rule.id }
}

output "outbound_rule_ids" {
  description = "Map of outbound rule IDs keyed by name."
  value       = { for name, rule in azurerm_lb_outbound_rule.this : name => rule.id }
}

output "tags" {
  description = "Effective tags applied to the Load Balancer."
  value       = local.tags
}
