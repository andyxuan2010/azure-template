# Management Groups Quick Reference

- Required inputs: `display_name`
- Optional hierarchy inputs: `name`, `parent_management_group_id`, `subscription_ids`
- `subscription_ids` are managed by the management group resource.
- Primary output: `id`
- Typical dependency chain: `managementgroups -> policy`
- Tests are plan-only with mock providers.
