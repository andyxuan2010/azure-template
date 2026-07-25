# Load Balancer Quick Reference

- Frontends specify exactly one of `public_ip_address_id` or `subnet_id`.
- Static private frontends require `private_ip_address`.
- Rules validate frontend, backend-pool, and probe references.
- Outbound rules require Standard SKU.
- Explicit `tags` override `inherited_resource_group_tags`.
- Test with `terraform test`.
