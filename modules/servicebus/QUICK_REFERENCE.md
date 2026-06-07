# Service Bus Quick Reference

- Required inputs: `resource_group_name`, `location`
- Optional core inputs: `name`, `queues`, `topics`, `subscriptions`, `authorization_rules`
- Optional security inputs: `enable_network_rule_set`, `enable_private_endpoint`, `app_admin_group`, `app_user_group`
- Primary output: `id`
- Typical dependency chain: `rg -> vnet -> servicebus`
