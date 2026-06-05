# Azure AI Search Quick Reference

Purpose: Provision a secure, standardized Azure AI Search service with optional private endpoint, shared private links, diagnostics, identity, RBAC, and scale controls.

## Required Inputs

- `resource_group_name`: target resource group name.

## Common Inputs

- `location`: Azure region. Leave empty to read the resource group location.
- `name`: explicit Search service name. Leave empty for generated naming.
- `workload_name`, `app_env`, `location_code`, `instance`, `use_random_suffix`: generated naming controls.
- `sku`, `replica_count`, `partition_count`, `hosting_mode`, `semantic_search_sku`: Search capacity and capability controls.
- `public_network_access_enabled`: defaults to `false`.
- `local_authentication_enabled`: defaults to `false`.
- `allowed_ips`, `network_rule_bypass_option`: public network firewall controls.
- `system_managed_identity_enabled`, `identity_ids`, `identity`: managed identity controls.
- `enable_private_endpoint`, `private_endpoint_subnet_id`, `private_dns_zone_ids`: inbound private endpoint configuration.
- `shared_private_link_services`: outbound private access to dependency resources.
- `app_admin_group`, `app_user_group`, `role_assignments`: RBAC controls.
- `enable_diagnostics`, `log_analytics_workspace_id`, `diagnostic_storage_account_id`, `diagnostic_eventhub_authorization_rule_id`: diagnostic settings.

## Primary Outputs

- `id`, `name`, `resource_group_name`, `location`, `endpoint`
- `sku`, `replica_count`, `partition_count`, `hosting_mode`, `semantic_search_sku`
- `identity`, `identity_type`, `principal_id`, `tenant_id`
- `private_endpoint_id`, `private_endpoint_name`
- `shared_private_link_service_ids`, `shared_private_link_service_statuses`
- `diagnostics_enabled`, `diagnostic_setting_id`
- `role_assignment_ids`, `role_assignment_count`
- `tags`

## Validation Commands

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```
