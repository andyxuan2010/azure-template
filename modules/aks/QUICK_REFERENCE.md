# Azure Kubernetes Service Quick Reference

Purpose: Provision AKS with private-cluster-first defaults, Azure RBAC, workload identity, Azure Policy, and optional diagnostics.

## Required Inputs

- `resource_group_name`: `string`

## Important Optional Inputs

- `name`: `string`
- `node_resource_group_name`: `string`
- `private_cluster_enabled`: `bool`
- `private_cluster_public_fqdn_enabled`: `bool`
- `api_server_authorized_ip_ranges`: `list(string)`
- `automatic_upgrade_channel`: `string`
- `node_os_upgrade_channel`: `string`
- `default_node_pool`: `object`
- `network_profile`: `object`
- `azure_policy_enabled`: `bool`
- `image_cleaner_enabled`: `bool`
- `image_cleaner_interval_hours`: `number`
- `key_vault_secrets_provider_enabled`: `bool`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `terraform_execution_aks_role`: `string`

## Primary Outputs

- `id`
- `name`
- `fqdn`
- `private_fqdn`
- `node_resource_group`
- `identity_principal_id`
- `kubelet_identity`
- `oidc_issuer_url`
- `azure_policy_enabled`
- `image_cleaner_enabled`
- `private_dns_zone_id`
- `diagnostic_setting_id`

## Best-Practice Defaults

- Private cluster enabled
- Local account disabled
- OIDC issuer enabled
- Workload identity enabled
- Azure RBAC enabled
- Azure Policy enabled
- Image cleaner enabled

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
