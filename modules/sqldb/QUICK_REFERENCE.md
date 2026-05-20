# SQL Database Quick Reference

Purpose: provision an Azure SQL logical server and database with private networking, Entra admin, TDE, backup retention, auditing, diagnostics, RBAC, and optional failover.

## Minimum Practical Inputs

- `resource_group_name`: Target resource group.
- `location`: Azure region, unless you want the module to read the resource group location.
- `ad_admin_login_name`: Microsoft Entra admin login name.
- `ad_admin_object_id`: Microsoft Entra admin object ID.
- `private_endpoint_subnet_id`: Required by default because `enable_private_endpoint = true`.
- `admin_username` and `admin_password`: Required unless using Key Vault-backed secrets or `azuread_authentication_only = true`.

## Common Options

- `server_name`, `database_name`: Explicit names. Leave empty for generated names.
- `workload_name`, `location_code`, `instance`, `use_random_suffix`: Generated naming controls.
- `sku_name`, `max_size_gb`, `zone_redundant`: Database capacity and resiliency.
- `backup_retention_days`, `enable_long_term_retention`: Backup controls.
- `enable_audit`, `enable_database_audit`: Auditing controls.
- `enable_threat_detection`, `enable_database_threat_detection`: Microsoft Defender for SQL alert policies.
- `enable_diagnostics`, `log_analytics_workspace_id`: Azure Monitor diagnostics.
- `identity_ids`, `primary_user_assigned_identity_id`: Server user-assigned identity and CMK support.
- `database_identity_ids`: Database user-assigned identity for database-level CMK.
- `role_assignments`: Custom Azure RBAC assignments.
- `failover_group`: Optional SQL failover group.

## Secure Production Defaults To Keep

- `public_network_access_enabled = false`
- `minimum_tls_version = "1.2"`
- `transparent_data_encryption_enabled = true`
- `system_assigned_identity_enabled = true`
- `azuread_administrator_enabled = true`

## Common Outputs

- `server_name`
- `server_fqdn`
- `database_name`
- `server_id`
- `database_id`
- `private_endpoint_id`
- `diagnostic_setting_id`
- `backup_configuration`
- `security_configuration`
- `role_assignment_count`
- `tags`

## Commands

```powershell
terraform -chdir=modules\sqldb fmt
terraform -chdir=modules\sqldb validate
terraform -chdir=modules\sqldb test
```
