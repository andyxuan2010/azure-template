# Availability Set Examples

## Basic Availability Set

```hcl
module "availabilityset" {
  source = "./modules/availabilityset"

  resource_group_name = "rg-platform-dev"
  location            = "canadacentral"
  workload_name       = "platform"
  app_env             = "dev"

  tags = {
    Environment = "Development"
    Owner       = "CCOE"
  }
}
```

## Explicit Name And Domain Counts

```hcl
module "availabilityset" {
  source = "./modules/availabilityset"

  name                = "avail-api-cc-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"

  platform_fault_domain_count  = 3
  platform_update_domain_count = 10
}
```

## Root Harness

```hcl
features = {
  enable_availabilityset = true
}

availabilitysets = {
  "001" = {
    name                         = "avail-api-cc-dev-001"
    platform_fault_domain_count  = 2
    platform_update_domain_count = 5
    tags = {
      Workload = "api"
    }
  }
}
```

Use `module_plan_enabled.availabilityset = true` instead of `features.enable_availabilityset` for focused one-module root plans.
