output "id" {
  description = "List of Linux virtual machine IDs."
  value       = [for vm in azurerm_linux_virtual_machine.this : vm.id]
}

output "name" {
  description = "List of Linux virtual machine names."
  value       = [for vm in azurerm_linux_virtual_machine.this : vm.name]
}

output "computer_name" {
  description = "List of Linux VM computer names."
  value       = [for vm in azurerm_linux_virtual_machine.this : vm.computer_name]
}

output "private_ip" {
  description = "List of private IP addresses assigned to the VM NICs."
  value       = [for nic in azurerm_network_interface.this : nic.private_ip_address]
}

output "private_ip_by_vm_name" {
  description = "Map of Linux VM name to private IP address."
  value = {
    for idx, vm in azurerm_linux_virtual_machine.this :
    vm.name => azurerm_network_interface.this[idx].private_ip_address
  }
}

output "public_ip" {
  description = "List of public IP addresses, if public networking is enabled."
  value       = [for pip in azurerm_public_ip.this : pip.ip_address]
}

output "public_ip_ids" {
  description = "List of public IP resource IDs, if public networking is enabled."
  value       = [for pip in azurerm_public_ip.this : pip.id]
}

output "network_interface_ids" {
  description = "List of network interface IDs."
  value       = [for nic in azurerm_network_interface.this : nic.id]
}

output "network_interface_names" {
  description = "List of network interface names."
  value       = [for nic in azurerm_network_interface.this : nic.name]
}

output "managed_identity_principal_ids" {
  description = "List of system-assigned managed identity principal IDs. Returns an empty list when system-assigned identity is disabled."
  value       = var.enable_system_assigned_identity ? [for vm in azurerm_linux_virtual_machine.this : vm.identity[0].principal_id] : []
}

output "managed_disk_ids" {
  description = "List of managed data disk IDs."
  value       = [for disk in azurerm_managed_disk.this : disk.id]
}

output "role_assignment_ids" {
  description = "Role assignment IDs created for VM resource RBAC, NIC resource RBAC, optional Entra VM login RBAC, Storage Blob Data Contributor, optional localization Storage Blob Data Reader, Key Vault Reader, and Key Vault Secrets User."
  value = {
    vm_resource_contributor               = [for role in azurerm_role_assignment.vm_resource_admin : role.id]
    nic_resource_contributor              = [for role in azurerm_role_assignment.nic_resource_admin : role.id]
    vm_resource_reader                    = [for role in azurerm_role_assignment.vm_resource_user : role.id]
    vm_entra_admin_login                  = [for role in azurerm_role_assignment.vm_entra_admin_login : role.id]
    vm_entra_user_login                   = [for role in azurerm_role_assignment.vm_entra_user_login : role.id]
    storage_blob_data_contributor         = [for role in azurerm_role_assignment.vm2st : role.id]
    storage_blob_data_reader_localization = [for role in azurerm_role_assignment.vm2st_localization_reader : role.id]
    key_vault_reader                      = [for role in azurerm_role_assignment.vm2kv : role.id]
    key_vault_secrets_user                = [for role in azurerm_role_assignment.vm2kvsecrets : role.id]
  }
}

output "entra_ssh_login_extension_ids" {
  description = "List of Entra SSH login VM extension IDs, if enabled."
  value       = [for extension in azurerm_virtual_machine_extension.entra_ssh_login : extension.id]
}

output "linux_vm_extension_ids" {
  description = "List of localization CustomScript VM extension IDs, if enabled."
  value       = [for extension in azurerm_virtual_machine_extension.vm_extension_linux : extension.id]
}

output "network_security_group_ids" {
  description = "List of network security group IDs created for public networking, if enabled."
  value       = [for nsg in azurerm_network_security_group.this : nsg.id]
}

output "network_security_group_names" {
  description = "List of network security group names created for public networking, if enabled."
  value       = [for nsg in azurerm_network_security_group.this : nsg.name]
}

output "tags" {
  description = "The effective tags assigned to the Linux VM resources."
  value       = local.tags
}
