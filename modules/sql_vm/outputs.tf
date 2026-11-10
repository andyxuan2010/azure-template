output "ids" {
  description = "Map of SQL VM Azure VM resource IDs by instance key."
  value       = { for key, vm in azurerm_windows_virtual_machine.this : key => vm.id }
}

output "names" {
  description = "Map of SQL VM names by instance key."
  value       = { for key, vm in azurerm_windows_virtual_machine.this : key => vm.name }
}

output "computer_names" {
  description = "Map of Windows computer names by instance key."
  value       = { for key, vm in azurerm_windows_virtual_machine.this : key => vm.computer_name }
}

output "network_interface_ids" {
  description = "Map of NIC IDs by instance key."
  value       = { for key, nic in azurerm_network_interface.this : key => nic.id }
}

output "private_ip_addresses" {
  description = "Map of private IP addresses by instance key."
  value       = { for key, nic in azurerm_network_interface.this : key => nic.private_ip_address }
}

output "managed_disk_ids" {
  description = "Map of managed data disk IDs by compound key '<vm_index>|<disk_key>'."
  value       = { for key, disk in azurerm_managed_disk.this : key => disk.id }
}

output "sql_virtual_machine_ids" {
  description = "Map of Azure SQL VM registration IDs by instance key."
  value       = { for key, sqlvm in azurerm_mssql_virtual_machine.this : key => sqlvm.id }
}

output "location" {
  description = "Resolved Azure region."
  value       = local.resolved_location
}

output "location_code" {
  description = "Short location code used for generated naming."
  value       = local.location_code
}

output "tags" {
  description = "Effective tags applied to SQL VM resources."
  value       = local.tags
}
