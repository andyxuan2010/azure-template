# AKS Quick Reference

Purpose: Provision AKS clusters with secure defaults, standardized naming and tags, advanced networking, managed identities, node pools, observability, diagnostics, and RBAC.

## Required Inputs

- `resource_group_name`: Existing resource group name.

## Common Naming Inputs

- `name`: Explicit AKS cluster name. Leave empty for generated naming.
- `workload_name`: Workload segment for generated naming.
- `app_env`: `prod`, `staging`, `dev`, `sbx`, `test`, `qa`, or `poc`.
- `location_code`: Optional short region code.
- `use_random_suffix`: Adds random suffix to generated names.

## Security Defaults

- `private_cluster_enabled`: Defaults to `true`.
- `azure_rbac_enabled`: Defaults to `true`.
- `local_account_disabled`: Defaults to `true`.
- `oidc_issuer_enabled`: Defaults to `true`.
- `workload_identity_enabled`: Defaults to `true`.
- `azure_policy_enabled`: Defaults to `true`.
- `image_cleaner_enabled`: Defaults to `true`.

## Core Inputs

- `default_node_pool`: System node pool configuration.
- `node_pools`: Additional node pools.
- `identity_ids`: Optional user-assigned control-plane identity IDs.
- `kubelet_identity`: Optional kubelet user-assigned identity.
- `network_profile`: AKS network profile.
- `api_server_access_profile`: API server VNet integration and authorized ranges.
- `private_dns_zone_id`: `System`, `None`, or private DNS zone resource ID.
- `private_dns_zone_name`: Existing private DNS zone lookup name.

## Add-ons

- `oms_agent_enabled`: Container Insights.
- `microsoft_defender_enabled`: Defender for Containers.
- `monitor_metrics_enabled`: Managed Prometheus metrics profile.
- `key_vault_secrets_provider_enabled`: Key Vault Secrets Store CSI driver.
- `storage_profile`: CSI driver profile.
- `workload_autoscaler_profile`: KEDA and VPA.
- `ingress_application_gateway`: AGIC add-on.
- `web_app_routing`: Web App Routing add-on.

## Diagnostics And RBAC

- `enable_diagnostics`: Creates diagnostic setting when a destination is supplied.
- `log_analytics_workspace_id`: Log Analytics destination and shared add-on workspace.
- `diagnostic_storage_account_id`: Archive destination.
- `diagnostic_eventhub_authorization_rule_id`: Event Hub streaming destination.
- `app_admin_group`: Entra groups receiving admin treatment.
- `app_user_group`: Entra groups receiving reader treatment.
- `role_assignments`: Additional cluster-scope Azure role assignments.

## Primary Outputs

- `id`, `name`, `resource_group_name`, `location`
- `fqdn`, `private_fqdn`, `portal_fqdn`
- `private_dns_zone_id`, `private_cluster_enabled`
- `identity_type`, `identity_principal_id`, `identity_tenant_id`, `kubelet_identity`
- `node_pool_ids`, `node_pool_names`
- `oidc_issuer_url`, `workload_identity_enabled`
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
