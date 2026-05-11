# Azure Kubernetes Service Quick Reference

Purpose: Provision Azure Kubernetes Service with RBAC, networking, private cluster options, and diagnostics.

## Required Inputs

- `resource_group_name`: `string`

## Common Optional Inputs

- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `diagnostic_log_categories`: `list(string)`
- `diagnostic_metric_categories`: `list(string)`
- `enable_diagnostics`: `bool`
- `log_analytics_workspace_id`: `string`
- `tags`: `map(string)`
- `terraform_execution_aks_role`: `string`
- `workload_identity_enabled`: `bool`

## Primary Outputs

- `app_admin_group_role_assignment_ids`
- `app_user_group_role_assignment_ids`
- `diagnostic_setting_id`
- `fqdn`
- `id`
- `identity_principal_id`
- `identity_tenant_id`
- `kubelet_identity`
- `kubernetes_version`
- `location`
- `name`
- `node_resource_group`
- `terraform_execution_identity_cluster_access_role_assignment_id`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```

## Access Note

When `azure_rbac_enabled = true`, Azure subscription roles such as `Contributor` do not by themselves grant `kubectl` access to cluster resources. Use `terraform_execution_aks_role` if the Terraform service principal must access the AKS cluster through Azure Kubernetes Service RBAC.
