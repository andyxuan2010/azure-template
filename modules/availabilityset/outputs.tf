output "id" {
  description = "The ID of the Availability Set."
  value       = azurerm_availability_set.this.id
}

output "name" {
  description = "The name of the Availability Set."
  value       = azurerm_availability_set.this.name
}

output "resource_group_name" {
  description = "The resource group containing the Availability Set."
  value       = azurerm_availability_set.this.resource_group_name
}

output "location" {
  description = "The Azure region of the Availability Set."
  value       = azurerm_availability_set.this.location
}

output "location_code" {
  description = "The short location code used for generated naming."
  value       = local.location_code
}

output "platform_fault_domain_count" {
  description = "The configured fault domain count."
  value       = azurerm_availability_set.this.platform_fault_domain_count
}

output "platform_update_domain_count" {
  description = "The configured update domain count."
  value       = azurerm_availability_set.this.platform_update_domain_count
}

output "managed" {
  description = "Whether the Availability Set is managed."
  value       = azurerm_availability_set.this.managed
}

output "proximity_placement_group_id" {
  description = "The proximity placement group ID assigned to the Availability Set, if any."
  value       = azurerm_availability_set.this.proximity_placement_group_id
}

output "tags" {
  description = "Effective tags applied to the Availability Set."
  value       = local.tags
}
