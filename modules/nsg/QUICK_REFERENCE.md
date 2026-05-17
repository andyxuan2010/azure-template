# NSG Quick Reference

- Required inputs: `name`, `resource_group_name`, `location`
- Optional networking inputs: `security_rules`, `subnet_ids`, `network_interface_ids`
- Primary output: `id`
- Typical dependency chain: `rg -> vnet -> nsg`
