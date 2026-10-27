output "id" {
  description = "NAT Gateway resource ID."
  value       = azurerm_nat_gateway.this.id
}

output "name" {
  description = "NAT Gateway name."
  value       = azurerm_nat_gateway.this.name
}

output "resource_guid" {
  description = "NAT Gateway resource GUID."
  value       = azurerm_nat_gateway.this.resource_guid
}

output "sku_name" {
  description = "NAT Gateway SKU."
  value       = azurerm_nat_gateway.this.sku_name
}

output "public_ip_address_ids" {
  description = "Public IP resource IDs associated with the NAT Gateway."
  value       = local.public_ip_address_ids
}

output "managed_public_ip_addresses" {
  description = "Allocated IP addresses for public IPs created by this module. Empty when caller-owned public IP IDs are used."
  value       = [for public_ip in azurerm_public_ip.this : public_ip.ip_address]
}

output "public_ip_association_ids" {
  description = "NAT Gateway public IP association IDs keyed by the stable association key."
  value       = { for key, association in azurerm_nat_gateway_public_ip_association.this : key => association.id }
}

output "subnet_association_ids" {
  description = "Subnet association IDs keyed by subnet resource ID."
  value       = { for subnet_id, association in azurerm_subnet_nat_gateway_association.this : subnet_id => association.id }
}

output "tags" {
  description = "Effective tags applied to the NAT Gateway and module-created public IPs."
  value       = local.tags
}
