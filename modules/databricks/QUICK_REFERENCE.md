# Databricks Quick Reference

Purpose: Provision a secure, standardized Azure Databricks workspace with optional VNet injection, access connector, CMK, private endpoints, diagnostics, and RBAC.

## Required Inputs

- `resource_group_name`: target resource group name.

## Common Inputs

- `location`: Azure region. Leave empty to read the resource group location.
- `name`: explicit workspace name. Leave empty for generated naming.
- `workload_name`, `app_env`, `location_code`, `instance`, `use_random_suffix`: generated naming controls.
- `sku`: `standard`, `premium`, or `trial`; premium is required for security/compliance options.
- `public_network_access_enabled`: defaults to `false`.
- `custom_parameters`: VNet injection, no-public-IP, managed VNet, storage, and ML linkage settings.
- `custom_parameters.storage_account_name`: optional Databricks default storage account name. When set, app groups receive storage-account scoped RBAC.
- `enhanced_security_compliance`: automatic cluster update, monitoring, and compliance profile settings.
- `create_access_connector`, `access_connector_id`, `default_storage_firewall_enabled`: Unity Catalog and storage firewall controls.
- `managed_disk_cmk_*`, `managed_services_cmk_*`, `root_dbfs_customer_managed_key`: CMK controls.
- `private_endpoint_subresource_names`, `private_endpoint_subnet_id`, `private_dns_zone_ids`: private endpoint configuration.
- `app_admin_group`, `app_user_group`, `role_assignments`, `access_connector_role_assignments`: RBAC controls. App admins receive workspace Contributor, and app users receive workspace Reader. When `custom_parameters.storage_account_name` is set, app admins also receive storage Contributor and Storage Blob Data Contributor, and app users receive storage Reader and Storage Blob Data Reader.
- `enable_diagnostics`, `log_analytics_workspace_id`, `diagnostic_storage_account_id`, `diagnostic_eventhub_authorization_rule_id`: diagnostic settings.

## Primary Outputs

- `id`, `name`, `resource_group_name`, `location`
- `workspace_id`, `workspace_url`, `managed_resource_group_id`, `managed_resource_group_name`
- `access_connector_id`, `access_connector_identity`
- `private_endpoint_ids`, `private_endpoint_names`
- `root_dbfs_customer_managed_key_id`
- `diagnostics_enabled`, `diagnostic_setting_id`
- `role_assignment_ids`, `access_connector_role_assignment_ids`, storage account role assignment ID outputs, `role_assignment_count`
- `tags`

## Validation Commands

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```
