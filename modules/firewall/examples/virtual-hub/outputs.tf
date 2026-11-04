output "firewall_id" {
  description = "Virtual Hub Azure Firewall resource ID."
  value       = module.firewall.id
}

output "firewall_policy_id" {
  description = "Attached Firewall Policy resource ID."
  value       = module.firewall.firewall_policy_id
}
