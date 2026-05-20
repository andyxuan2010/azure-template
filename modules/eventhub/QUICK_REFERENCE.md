# Event Hub Quick Reference

- Required input: `resource_group_name`.
- Recommended inputs: `location`, `workload_name`, `app_env`, `eventhubs`.
- Secure defaults: `public_network_access_enabled = false`, `local_authentication_enabled = false`, TLS 1.2.
- Private endpoint: set `enable_private_endpoint = true`, provide a subnet, and attach `privatelink.servicebus.windows.net`.
- SAS rules: set `local_authentication_enabled = true`, then use `authorization_rules` or per-Event Hub `authorization_rules`.
- Streaming features: use `eventhubs` for retention, Capture, consumer groups, and Event Hub-scoped rules.
- Governance features: use `schema_groups`, `role_assignments`, `customer_managed_key`, and diagnostics destinations.
- Primary outputs: `id`, `name`, `eventhub_ids`, `consumer_group_ids`, `diagnostic_setting_id`.
