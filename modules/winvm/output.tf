output "privateips" {
  value = azurerm_network_interface.this[*].private_ip_address
}

# Output Public IP (if provisioned)
output "public_ip" {
  value = var.public_network_enabled ? azurerm_public_ip.this[0].ip_address : "No Public IP Assigned"
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
  value       = local.merged_tags
}

output "diagnostics_enabled" {
  description = "Whether VM diagnostics were configured"
  value       = var.enable_diagnostics
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
