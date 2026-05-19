# Resource Group Examples

These examples use the standardized `rg` module interface.

## Explicit Production Resource Group

```hcl
module "rg" {
  source = "./modules/rg"

  name     = "rg-contoso-prod-eus-001"
  location = "eastus"
  app_env  = "prod"

  enable_lock = true
  lock_level  = "CanNotDelete"

  tags = {
    Owner = "CCOE"
    IaC   = "Terraform"
  }
}
```

## Deterministic Generated Name

```hcl
module "rg" {
  source = "./modules/rg"

  name                        = ""
  name_prefix                 = "rg"
  workload_name               = "shared"
  app_env                     = "poc"
  include_environment_in_name = true
  location                    = "eastus"
  location_code               = "eus"
  instance                    = "001"
  use_random_suffix           = false
}
```

The generated name is `rg-shared-poc-eus-001`.

## Built-In Group Shortcuts

```hcl
module "rg" {
  source = "./modules/rg"

  name     = "rg-contoso-dev-eus-001"
  location = "eastus"
  app_env  = "dev"

  app_admin_group = [
    "00000000-0000-0000-0000-000000000000"
  ]

  app_user_group = [
    "11111111-1111-1111-1111-111111111111"
  ]
}
```

## Additional Role Assignments

```hcl
module "rg" {
  source = "./modules/rg"

  name     = "rg-contoso-prod-ops"
  location = "eastus"
  app_env  = "prod"

  role_assignments = {
    monitoring_reader = {
      principal_id         = "22222222-2222-2222-2222-222222222222"
      principal_type       = "Group"
      role_definition_name = "Monitoring Reader"
      description          = "Read monitoring data at the resource group scope."
    }

    custom_operator = {
      principal_id       = "33333333-3333-3333-3333-333333333333"
      principal_type     = "ServicePrincipal"
      role_definition_id = "/subscriptions/<subscription-id>/providers/Microsoft.Authorization/roleDefinitions/<role-definition-id>"
    }
  }
}
```

## Notes

- Prefer object IDs over display names for `app_admin_group` and `app_user_group`.
- Set exactly one of `role_definition_name` or `role_definition_id` in each `role_assignments` entry.
- Related test coverage lives in `tests/live.tftest.hcl`.
