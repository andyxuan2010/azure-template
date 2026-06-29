# NSG Quick Reference

- Required inputs: `name`, `resource_group_name`, `location`
- Optional networking inputs: `security_rules`, `subnet_ids`, `network_interface_ids`
- Rules validate priority, protocol, direction, access, and mutually exclusive fields.
- Primary output: `id`
- Typical dependency chain: `rg -> vnet -> nsg`
- Tests are plan-only with a mock Azure provider.
