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

output "virtual_network_id" {
  description = "Created dedicated VNet ID, or null when a shared VNet is used."
  value       = local.vnet_id
}

output "virtual_network_name" {
  description = "Effective VNet name containing the FortiGate subnets."
  value       = local.vnet_name
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

output "app_admin_group_principal_ids" {
  description = "Map of resolved app admin group principal IDs."
  value       = local.app_admin_group_principal_ids
}

output "app_user_group_principal_ids" {
  description = "Map of resolved app user group principal IDs."
  value       = local.app_user_group_principal_ids
}

output "app_admin_group_role_assignment_ids" {
  description = "Contributor role assignment IDs for app_admin_group on FortiGate VMs and NICs."
  value = {
    virtual_machines   = { for key, assignment in azurerm_role_assignment.vm_app_admin_group : key => assignment.id }
    network_interfaces = { for key, assignment in azurerm_role_assignment.nic_app_admin_group : key => assignment.id }
  }
}

output "app_user_group_role_assignment_ids" {
  description = "Reader role assignment IDs for app_user_group on FortiGate VMs."
  value       = { for key, assignment in azurerm_role_assignment.vm_app_user_group : key => assignment.id }
}
