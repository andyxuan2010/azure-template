# Firewall Quick Reference

- Required inputs: `resource_group_name`; plus `subnet_id` for `AZFW_VNet` or `virtual_hub_id` for `AZFW_Hub`.
- Recommended production inputs: `location`, `workload_name`, `app_env`, `zones`, diagnostics destination.
- Secure defaults: Firewall Policy created by default, DNS proxy enabled, threat intelligence mode `Deny`.
- Public IPs: use created Standard static IPs by default, or set `create_public_ip = false` and supply `public_ip_ids`.
- Forced tunneling: set `management_subnet_id` for `AzureFirewallManagementSubnet`.
- Rules: prefer `rule_collection_groups`; legacy collection inputs still populate a default group.
- Premium: set `sku_tier = "Premium"` and `firewall_policy_sku = "Premium"` for IDPS, TLS inspection, and URL/web-category rules.
- Primary outputs: `id`, `name`, `private_ip_address`, `public_ip_ids`, `firewall_policy_id`, `rule_collection_group_ids`.
