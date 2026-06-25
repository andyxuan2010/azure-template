# Policy Quick Reference

- Required inputs: `name`, `display_name`, `policy_rule`
- Optional governance inputs: `management_group_id`, `create_assignment`, `assignment_scope`
- Assignment controls: `assignment_metadata`, `assignment_not_scopes`, `non_compliance_messages`, `identity_type`, `assignment_timeouts`
- Primary output: `policy_definition_id`
- Typical dependency chain: `managementgroups -> policy`
