# Azure Kubernetes Service Examples

Examples below were regenerated from the current `aks` module interface.

## Example 1: Minimal

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-example-prod"
}
```

## Example 2: Common Pattern

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-example-prod"
  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
  enable_diagnostics = false
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/<provider>/<type>/<name>"
  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Example 3: Grant AKS Cluster Access To The Terraform Service Principal

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name = "rg-example-prod"
  azure_rbac_enabled  = true

  # Grants the current Terraform execution identity AKS Kubernetes RBAC access
  # on the cluster resource. This is useful when the pipeline service principal
  # needs to run kubectl against an Azure RBAC-enabled AKS cluster.
  terraform_execution_aks_role = "Azure Kubernetes Service RBAC Cluster Admin"
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- Use `terraform_execution_aks_role` only when the Terraform execution identity itself needs AKS data-plane access through Azure RBAC.

## Related Terraform Tests

- `tests/live.tftest.hcl`
