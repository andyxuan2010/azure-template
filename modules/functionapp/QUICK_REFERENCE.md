# Function App Quick Reference

Purpose: Provision Linux or Windows Azure Function Apps with secure defaults, standardized naming and tags, storage auth options, networking, private endpoint, diagnostics, Easy Auth, and RBAC.

## Required Inputs

- `resource_group_name`: Existing resource group name.
- `service_plan_id`: Existing App Service Plan resource ID.

## Common Identity And Storage Inputs

- `storage_account_name`: Storage account name for access-key or managed-identity storage auth.
- `storage_account_access_key`: Optional sensitive access key; avoids storage account data lookup.
- `storage_uses_managed_identity`: Use managed identity for `AzureWebJobsStorage`.
- `storage_key_vault_secret_id`: Key Vault secret URI containing the storage connection string.
- `system_assigned_identity_enabled`: Enable system-assigned identity.
- `identity_ids`: User-assigned identity IDs.
- `key_vault_reference_identity_id`: Identity used for Key Vault references in app settings.

## Runtime And Site Inputs

- `os_type`: `Linux` or `Windows`.
- `application_stack`: Exactly one runtime family: .NET, Java, Node, PowerShell, Python, custom runtime, or Linux Docker.
- `app_settings`: Function app settings.
- `connection_strings`: Function app connection strings.
- `auth_settings_v2`: App Service Authentication v2.
- `backup`: Backup schedule and storage SAS URL.
- `ip_restrictions` / `scm_ip_restrictions`: Main and SCM/Kudu network restrictions.

## Network And Diagnostics Inputs

- `public_network_access_enabled`: Defaults to `false`.
- `virtual_network_subnet_id`: Regional VNet integration subnet.
- `vnet_route_all_enabled`: Route all outbound traffic through VNet integration.
- `enable_private_endpoint`: Create private endpoint for `sites`.
- `private_endpoint_subnet_id`: Private endpoint subnet.
- `private_dns_zone_ids`: Private DNS zone IDs, typically `privatelink.azurewebsites.net`.
- `enable_diagnostics`: Create diagnostic setting.
- `log_analytics_workspace_id`, `diagnostic_storage_account_id`, `diagnostic_eventhub_authorization_rule_id`: Diagnostic destinations.

## Primary Outputs

- `id`, `name`, `default_hostname`, `resource_group_name`, `location`
- `identity_type`, `identity_principal_id`, `identity_tenant_id`, `identity_ids`
- `storage_account_id`, `storage_account_name`, `storage_auth_mode`
- `private_endpoint_id`, `private_endpoint_name`, `private_dns_zone_ids`
- `diagnostic_setting_id`, `diagnostics_enabled`
- `role_assignment_ids`, `role_assignment_count`
- `tags`

## Test Commands

```powershell
terraform init -backend=false
terraform validate
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
