# Azure Data Factory Examples

Examples below were regenerated from the current `adf` module interface.

## Example 1: Minimal

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "my-data-factory"
  app_env        = "dev"
  location       = "canadacentral"
  resource_group = "rg-example-prod"

  iac_rg      = "rg-iac"
  iac_kv      = "kv-iac"
  iac_st      = "st-iac"
  app_rg      = "rg-app"
  app_vnet_rg = "<app_vnet_rg>"
  app_vnet    = "vnet-app"
  app_snet    = "snet-app"
}
```

## Example 2: Common Pattern

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "my-data-factory"
  app_env        = "prod"
  location       = "canadacentral"
  resource_group = "rg-example-prod"

  iac_rg      = "rg-iac"
  iac_kv      = "kv-iac"
  iac_st      = "stiacprod001"
  app_rg      = "rg-app"
  app_vnet_rg = "rg-network"
  app_vnet    = "vnet-app"
  app_snet    = "snet-integration"

  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group = ["00000000-0000-0000-0000-000000000000"]
  identity_type = "SystemAssigned"
  public_network_enabled = false
  enable_private_endpoint = false
  vsts_configuration = {
    account_name    = "CCOE-Azure"
    project_name    = "CCoE-Infra-IaC"
    repository_name = "adf-config"
    branch_name     = "main"
    root_folder     = "/"
    tenant_id       = "00000000-0000-0000-0000-000000000000"
  }
  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Example 3: SHIR with GitHub

```hcl
module "adf" {
  source = "./modules/adf"

  name           = "my-data-factory"
  app_env        = "dev"
  location       = "canadacentral"
  resource_group = "rg-example-dev"

  iac_rg      = "rg-iac"
  iac_kv      = "kv-iac"
  iac_st      = "stiacdev001"
  app_rg      = "rg-app"
  app_vnet_rg = "rg-network"
  app_vnet    = "vnet-app"
  app_snet    = "snet-integration"
  app_vm      = "vm-adf-shir-01"

  self_hosted_integration_runtime_enabled = true

  github_configuration = {
    account_name    = "CCOE-Azure-Terraform"
    repository_name = "azure-template"
    branch_name     = "main"
    git_url         = "https://github.com/CCOE-Azure-Terraform/azure-template"
    root_folder     = "/"
  }
}
```

## Notes

- Replace placeholder IDs, names, and resource IDs with environment-specific values.
- Prefer Entra object IDs over display names when group names are duplicated.
- For private endpoint and diagnostics options, supply the full dependent inputs together.
- Set `app_vm` only when SHIR is enabled.
- Configure either `vsts_configuration` or `github_configuration`, not both.

## Related Terraform Tests

- `tests/live.tftest.hcl`
