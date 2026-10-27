output "id" {
  description = "Bastion host resource ID."
  value       = azurerm_bastion_host.this.id
}

output "name" {
  description = "Bastion host name."
  value       = azurerm_bastion_host.this.name
}

output "dns_name" {
  description = "Fully qualified domain name for the Bastion host."
  value       = azurerm_bastion_host.this.dns_name
}

output "subnet_id" {
  description = "Dedicated AzureBastionSubnet resource ID used by the host."
  value       = trimspace(var.subnet_id)
}

output "public_ip_address_id" {
  description = "Public IP resource ID attached to the Bastion host."
  value       = local.public_ip_address_id
}

output "public_ip_address" {
  description = "Allocated address for the module-created public IP, or null when using a caller-owned public IP."
  value       = local.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "sku" {
  description = "Bastion host SKU."
  value       = azurerm_bastion_host.this.sku
}

output "tags" {
  description = "Effective tags applied to the Bastion host and any module-created public IP."
  value       = local.tags
}

output "location" {
  description = "Azure region of the Bastion host."
  value       = azurerm_bastion_host.this.location
}
