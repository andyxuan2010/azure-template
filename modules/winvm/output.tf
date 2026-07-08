output "privateips" {
  value = azurerm_network_interface.this[*].private_ip_address
}

# Output Public IP (if provisioned)
output "public_ip" {
  description = "First public IP address for backward compatibility, or null when public networking is disabled."
  value       = try(azurerm_public_ip.this[0].ip_address, null)
}

output "public_ips" {
  description = "Public IP addresses for all VMs, or an empty list when public networking is disabled."
  value       = azurerm_public_ip.this[*].ip_address
}

output "vm_ids" {
  value = azurerm_windows_virtual_machine.this[*].id
}

output "principal_ids" {
  description = "The principal_id of the VM's system-assigned identity"
  value       = azurerm_windows_virtual_machine.this[*].identity[0].principal_id
}

output "merged_tags" {
  description = "Final merged tags applied to resources"
  value       = local.tags
}

output "diagnostics_enabled" {
  description = "Whether VM diagnostic settings were configured."
  value       = var.enable_diagnostics
}

output "diagnostic_setting_ids" {
  description = "Diagnostic setting IDs keyed by VM index."
  value       = { for index, setting in azurerm_monitor_diagnostic_setting.this : tostring(index) => setting.id }
}

output "role_assignment_ids" {
  description = "Role assignment IDs created for VM resource RBAC, NIC resource RBAC, VM login RBAC, Storage Blob Data Contributor, Key Vault Reader, Key Vault secrets access, and optional Data Factory Contributor."
  value = {
    vm_user_login            = [for role in azurerm_role_assignment.vm_user_login : role.id]
    vm_admin_login           = [for role in azurerm_role_assignment.vm_admin_login : role.id]
    vm_resource_contributor  = [for role in azurerm_role_assignment.vm_resource_admin : role.id]
    nic_resource_contributor = [for role in azurerm_role_assignment.nic_resource_admin : role.id]
    vm_resource_reader       = [for role in azurerm_role_assignment.vm_resource_user : role.id]
    storage_blob_contributor = [for role in azurerm_role_assignment.vm2st : role.id]
    key_vault_reader         = [for role in azurerm_role_assignment.vm2kv : role.id]
    key_vault_secrets_user   = [for role in azurerm_role_assignment.vm2kvsecrets : role.id]
    data_factory_contributor = [for role in azurerm_role_assignment.vm2adf : role.id]
  }
}
