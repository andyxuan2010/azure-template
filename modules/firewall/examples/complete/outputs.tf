output "firewall" {
  description = "Key production firewall values."
  value = {
    id                     = module.firewall.id
    name                   = module.firewall.name
    private_ip_address     = module.firewall.private_ip_address
    public_ip_addresses    = module.firewall.public_ip_addresses
    firewall_policy_id     = module.firewall.firewall_policy_id
    rule_collection_groups = module.firewall.rule_collection_group_ids
    diagnostic_setting_id  = module.firewall.diagnostic_setting_id
  }
}
