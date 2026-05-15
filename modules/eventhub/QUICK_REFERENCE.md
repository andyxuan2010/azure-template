# Event Hub Quick Reference

- Required inputs: `resource_group_name`, `location`
- Optional core inputs: `name`, `eventhubs`, `authorization_rules`
- Optional security inputs: `app_admin_group`, `app_user_group`, `enable_private_endpoint`
- Primary output: `id`
- Typical dependency chain: `rg -> vnet -> eventhub`
