# App Service Plan Examples

Pass `inherited_resource_group_tags` when the parent composition already knows the resource-group tags. Explicit `tags` values take precedence.

## Example 1: Minimal Linux Plan

```hcl
module "appserviceplan" {
  source = "./modules/appserviceplan"

  name                = "asp-platform-prod-001"
  app_env             = "prod"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  os_type             = "Linux"
  sku_name            = "B1"

  tags = {
    Owner = "CCOE"
  }
}
```

## Example 2: Autoscale with Notifications

```hcl
module "appserviceplan" {
  source = "./modules/appserviceplan"

  name                = "asp-platform-prod-001"
  app_env             = "prod"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  os_type             = "Linux"
  sku_name            = "B1"
  worker_count        = 1

  enable_autoscale           = true
  autoscale_default_capacity = 2
  autoscale_min_capacity     = 1
  autoscale_max_capacity     = 5
  enable_memory_autoscale    = true

  autoscale_notifications = {
    email = {
      custom_emails = ["ops@example.com"]
    }
    webhooks = [
      {
        service_uri = "https://hooks.example.com/autoscale"
        properties = {
          severity = "info"
        }
      }
    ]
  }
}
```

## Example 3: Zone-Balanced Premium Plan

```hcl
module "appserviceplan" {
  source = "./modules/appserviceplan"

  name                            = "asp-platform-prod-001"
  app_env                         = "prod"
  resource_group_name             = "rg-platform-prod"
  location                        = "canadacentral"
  os_type                         = "Linux"
  sku_name                        = "P1v4"
  worker_count                    = 3
  zone_balancing_enabled          = true
  premium_plan_auto_scale_enabled = true
}
```

## Example 4: Diagnostics to Log Analytics

```hcl
module "appserviceplan" {
  source = "./modules/appserviceplan"

  name                = "asp-platform-prod-001"
  app_env             = "prod"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  os_type             = "Linux"
  sku_name            = "B1"

  enable_diagnostics         = true
  log_analytics_workspace_id = "/subscriptions/<subscription-id>/resourceGroups/<rg>/providers/Microsoft.OperationalInsights/workspaces/<workspace-name>"
  diagnostic_metrics         = ["AllMetrics"]
}
```

## Example 5: Entra RBAC

```hcl
module "appserviceplan" {
  source = "./modules/appserviceplan"

  name                = "asp-platform-prod-001"
  app_env             = "prod"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  os_type             = "Linux"
  sku_name            = "B1"

  app_admin_group = ["00000000-0000-0000-0000-000000000000"]
  app_user_group  = ["App Service Plan Readers"]
}
```

## Notes

- Use `worker_count = 1` when Azure Monitor autoscale manages capacity.
- `zone_balancing_enabled` requires at least three workers.
- `premium_plan_auto_scale_enabled` is mutually exclusive with Azure Monitor autoscale in this module.
- Diagnostics require at least one destination: Log Analytics, Storage Account, or Event Hub.
