# Cosmos DB Quick Reference

Purpose: Provision Azure Cosmos DB accounts with secure defaults, SQL API databases and containers, managed identity, private endpoint, diagnostics, and RBAC.

## Required Inputs

- `resource_group_name`: Existing resource group name.

## Secure Defaults

- `public_network_access_enabled`: Defaults to `false`.
- `local_authentication_disabled`: Defaults to `true`.
- `system_assigned_identity_enabled`: Defaults to `true`.
- `minimal_tls_version`: Defaults to `Tls12`.
- `backup.type`: Defaults to `Continuous`.
- `diagnostic_log_categories`: Defaults to `["AllLogs"]`.

## Common Inputs

- `name`: Explicit account name. Leave empty for generated naming.
- `workload_name`, `app_env`, `location_code`, `instance`: Generated naming controls.
- `geo_locations`: Regions and failover priorities.
- `sql_databases`: SQL API databases.
- `sql_containers`: SQL API containers.
- `capabilities`: Account capabilities such as `EnableServerless`.
- `identity_ids`, `default_identity_type`, `key_vault_key_id`: Managed identity and CMK controls.
- `enable_private_endpoint`: Create private endpoint for `Sql`.
- `private_dns_zone_ids`: Private DNS zone IDs, typically `privatelink.documents.azure.com`.
- `enable_diagnostics`: Create diagnostic setting when a destination is supplied.
- `role_assignments`: Additional account-scope Azure role assignments.

## Primary Outputs

- `id`, `name`, `endpoint`
- `read_endpoints`, `write_endpoints`
- `public_network_access_enabled`, `local_authentication_disabled`
- `identity_type`
- `sql_database_ids`, `sql_container_ids`
- `private_endpoint_id`, `private_endpoint_name`, `private_dns_zone_ids`
- `diagnostics_enabled`, `diagnostic_setting_id`
- `role_assignment_ids`, `role_assignment_count`
- `tags`, `merged_tags`

## Test Commands

```powershell
terraform init -backend=false
terraform validate
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
