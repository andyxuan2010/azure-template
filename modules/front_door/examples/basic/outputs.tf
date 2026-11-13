output "frontdoor_endpoint" {
  description = "Default Azure Front Door endpoint hostname."
  value       = module.frontdoor.endpoint_host_name
}

output "profile_id" {
  description = "Azure Front Door profile resource ID."
  value       = module.frontdoor.profile_id
}
