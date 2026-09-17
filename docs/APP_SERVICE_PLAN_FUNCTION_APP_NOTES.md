# App Service Plan Notes for Function App

This template creates the App Service Plan in the root module and then binds the Function App to that same plan.

## Current Template Position

- `module "app_service_plan"` creates the hosting plan.
- `module "function_app_basic"` consumes the plan name and resource group from `module.app_service_plan`.
- The plan OS must match the Function App OS.

## SKU Guidance

- `B1` is appropriate for a simple fixed-capacity deployment where autoscale is disabled.
- `S1` or higher is a better fit if you expect sustained load, production growth, or future autoscale enablement.
- Premium SKUs such as `P1v3` should be considered when you need stronger performance and scaling headroom.

## Autoscale Guidance

- Autoscale is currently disabled in the root `app_service_plan` block.
- The autoscale capacity and threshold values are still present in `main.tf` as reference settings.
- Before enabling autoscale, review the selected SKU and move from `B1` to `S1` or higher.
- When autoscale is enabled, keep `worker_count = 1` and let autoscale manage instance count.

## Recommended Operating Model

- Keep `sku_name = "B1"` and `enable_autoscale = false` for low-cost fixed-capacity environments.
- Use `sku_name = "S1"` or higher if you plan to turn autoscale on.
- Update SKU and autoscale settings together so the hosting plan behavior remains intentional.
