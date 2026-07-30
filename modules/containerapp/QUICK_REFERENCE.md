# Container App Quick Reference

Required inputs:

- `resource_group_name`
- `container_app_environment_id`

Common inputs:

- `name`
- `workload`
- `app_env`
- `instance`
- `location`
- `containers`
- `ingress`
- `secrets`
- `registries`
- `min_replicas`
- `max_replicas`
- `identity_type`
- `identity_ids`

Naming:

- Override: `name = "ca-api-cc-prod-001"`
- Generated: `ca-<workload>-<region-code>-<app_env>-<instance>`

Root harness:

- Feature flag: `features.enable_containerapp`
- Focused module toggle: `module_plan_enabled.containerapp`
- Sample environment ID: `containerapp_environment_id`
