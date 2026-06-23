output "architecture" {
  description = "Effective FortiGate architecture profile."
  value       = local.architecture
}

output "virtual_machine_ids" {
  description = "FortiGate VM IDs keyed by instance suffix."
  value       = { for suffix, vm in azurerm_linux_virtual_machine.this : suffix => vm.id }
}

output "virtual_machine_names" {
  description = "FortiGate VM names keyed by instance suffix."
  value       = { for suffix, vm in azurerm_linux_virtual_machine.this : suffix => vm.name }
}

output "network_interface_ids" {
  description = "FortiGate NIC IDs keyed by <instance>-<interface>."
  value       = { for key, nic in azurerm_network_interface.this : key => nic.id }
}

output "private_ip_addresses" {
  description = "FortiGate private IP addresses keyed by <instance>-<interface>."
  value       = { for key, nic in azurerm_network_interface.this : key => nic.private_ip_address }
}

output "subnet_ids" {
  description = "Effective subnet IDs keyed by interface name."
  value       = local.interface_subnet_ids
}

output "network_security_group_id" {
  description = "Created NSG ID, or null when NSG creation is disabled."
  value       = try(azurerm_network_security_group.this[0].id, null)
}

output "internal_load_balancer_id" {
  description = "Internal load balancer ID, or null when disabled."
  value       = try(azurerm_lb.internal[0].id, null)
}

output "internal_load_balancer_frontend_ip" {
  description = "Internal load balancer frontend private IP address."
  value       = try(azurerm_lb.internal[0].frontend_ip_configuration[0].private_ip_address, null)
}

output "external_load_balancer_id" {
  description = "External-side load balancer ID, or null when disabled."
  value       = try(azurerm_lb.external[0].id, null)
}

output "external_public_ip_id" {
  description = "External load balancer public IP ID, or null when public frontend creation is disabled."
  value       = try(azurerm_public_ip.external_lb[0].id, null)
}

output "public_frontend_enabled" {
  description = "Whether this module creates a public frontend."
  value       = local.public_ip_enabled
}
