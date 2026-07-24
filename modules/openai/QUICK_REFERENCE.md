# OpenAI Quick Reference

Purpose: Provision Azure OpenAI accounts with secure defaults, standardized naming/tags, deployments, managed identity, private endpoint, diagnostics, and RBAC.

## Required Inputs

- `resource_group_name`: Existing resource group name.

## Secure Defaults

- `public_network_access_enabled`: Defaults to `false`.
- `local_auth_enabled`: Defaults to `false`.
- `system_assigned_identity_enabled`: Defaults to `true`.
- `custom_subdomain_name`: Defaults to the account name.
- `diagnostic_log_categories`: Defaults to `["AllLogs"]`.

## Common Inputs

- `name`: Explicit account name. Leave empty for generated naming.
- `workload_name`, `app_env`, `location_code`, `instance`: Generated naming controls.
- `deployments`: Azure OpenAI model deployments.
- `identity_ids`: User-assigned identity IDs.
- `customer_managed_key`: Key Vault CMK settings.
- `network_acls`: Account firewall rules.
- `enable_private_endpoint`: Create private endpoint for `account`.
- `private_dns_zone_ids`: Private DNS zone IDs, typically `privatelink.openai.azure.com`.
- `enable_diagnostics`: Create diagnostic setting when a destination is supplied.
- `role_assignments`: Additional account-scope Azure role assignments.
- `inherited_resource_group_tags`: plan-known resource-group tags; explicit `tags` take precedence.

Question Answering service ID/key, Event Hub diagnostic name/rule ID, and manual private endpoint/message inputs are validated as pairs.

## Primary Outputs

- `id`, `name`, `endpoint`, `custom_subdomain_name`
- `public_network_access_enabled`, `local_auth_enabled`
- `deployment_ids`, `deployment_names`, `deployment_details`
- `identity`, `identity_type`, `identity_ids`
- `private_endpoint_id`, `private_endpoint_name`, `private_dns_zone_ids`
- `diagnostics_enabled`, `diagnostic_setting_id`
- `role_assignment_ids`, `role_assignment_count`
- `tags`

## Test Commands

```powershell
terraform init -backend=false
terraform validate
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
