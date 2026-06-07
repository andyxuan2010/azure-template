# App Service Quick Reference

Purpose: provision a Linux or Windows Azure Web App with standardized tagging, secure publishing defaults, optional Easy Auth, diagnostics, private endpoint, storage mounts, custom domains, and deployment-center support.

## Required Inputs

- `app_name`: globally unique Web App name.
- `resource_group_name`: target resource group.
- `app_service_plan_id`: App Service Plan ID using the `serverFarms` segment.
- `location`: optional. Leave empty to inherit the resource group location.

## Common Production Inputs

- `app_env`: `prod`, `staging`, `dev`, `qa`, `sbx`, `test`, or `poc`.
- `kind`: `Linux` or `Windows`.
- `application_stack`: runtime or container stack.
- `always_on`: set `true` for production SKUs that support it.
- `public_network_access_enabled`: set `false` when using private endpoint.
- `vnet_route_all_enabled`: route outbound traffic through VNet integration.
- `minimum_tls_version` and `scm_minimum_tls_version`: use `1.2` or newer.
- `enable_diagnostics`: enable Azure Monitor diagnostic settings.
- `log_analytics_workspace_id`, `diagnostic_storage_account_id`, `diagnostic_eventhub_authorization_rule_id`: diagnostic destinations.
- `auth_mode`, `active_directory_client_id`, and `active_directory_allowed_groups`: Easy Auth configuration.
- `auto_heal_setting`: request/status-code based recycling.
- `backup`: App Service backup schedule and destination SAS URL.

## Primary Outputs

- `app_id`, `app_name`, `app_kind`, `location`.
- `default_hostname`, `default_url`.
- `identity_principal_id`, `identity_tenant_id`.
- `diagnostics_enabled`, `diagnostic_log_categories`, `diagnostic_metric_categories`.
- `auth_config`.
- `private_endpoint_sites_id`.
- `vnet_integration_subnet_id`.
- `merged_tags`.

## Test Commands

```powershell
terraform -chdir=modules\appservice fmt -check -recursive
terraform -chdir=modules\appservice validate
terraform -chdir=modules\appservice test
```

## Notes

- Avoid `DOCKER_*` app settings; configure containers through `application_stack`.
- Avoid build-number app settings in Terraform; the module intentionally ignores common CI/CD build keys.
- Keep FTP and SCM basic publishing credentials disabled unless a legacy deployment flow requires them.
