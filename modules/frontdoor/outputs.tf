output "profile_id" {
  description = "Azure Front Door profile resource ID."
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "profile_name" {
  description = "Azure Front Door profile name."
  value       = azurerm_cdn_frontdoor_profile.this.name
}

output "endpoint_id" {
  description = "Azure Front Door endpoint resource ID."
  value       = azurerm_cdn_frontdoor_endpoint.this.id
}

output "endpoint_host_name" {
  description = "Default Azure Front Door endpoint host name."
  value       = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "origin_group_id" {
  description = "Azure Front Door origin group resource ID."
  value       = azurerm_cdn_frontdoor_origin_group.this.id
}

output "origin_id" {
  description = "Azure Front Door origin resource ID."
  value       = azurerm_cdn_frontdoor_origin.this.id
}

output "route_id" {
  description = "Azure Front Door route resource ID."
  value       = azurerm_cdn_frontdoor_route.this.id
}

output "sku_name" {
  description = "Azure Front Door profile tier."
  value       = azurerm_cdn_frontdoor_profile.this.sku_name
}

output "tags" {
  description = "Effective tags applied to the profile and endpoint."
  value       = local.tags
}
