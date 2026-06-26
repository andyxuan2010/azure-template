# Quick Reference

- Module: `applicationgateway`
- Required inputs: `name`, `resource_group_name`, `location`, `subnet_id`, `http_listeners`, `request_routing_rules`
- Common companion inputs: `backend_address_pools`, `backend_http_settings`, `frontend_ports`, `autoscale_configuration`, `waf_configuration`
- Path routing: define `url_path_maps`, then reference a map with `url_path_map_name` from a `PathBasedRouting` rule.
- Diagnostics: set `log_analytics_workspace_id` plus at least one log or metric category.
- Tags: `tags` override `inherited_resource_group_tags`; supplying inherited tags avoids a resource-group data lookup.
- Test command: `terraform test -filter='tests\live.tftest.hcl'`
