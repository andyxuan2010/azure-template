# Quick Reference

- Module: `applicationgateway`
- Required inputs: `name`, `resource_group_name`, `location`, `subnet_id`, `http_listeners`, `request_routing_rules`
- Common companion inputs: `backend_address_pools`, `backend_http_settings`, `frontend_ports`, `autoscale_configuration`, `waf_configuration`
- Test command: `terraform test -filter='tests\live.tftest.hcl'`
