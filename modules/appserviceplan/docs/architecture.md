# Azure App Service Plan Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["appserviceplan module"]
  Module --> R1["azurerm_service_plan"]
  Module --> R2["azurerm_role_assignment"]
  Module --> R3["azurerm_monitor_diagnostic_setting"]
  Module --> R4["azurerm_monitor_autoscale_setting"]
```

The appserviceplan module declares 4 managed resource type(s), including `azurerm_service_plan`, `azurerm_role_assignment`, `azurerm_monitor_diagnostic_setting`, `azurerm_monitor_autoscale_setting`.

Resources that use `count` or `for_each` are gated by inputs such as `location`, `inherit_resource_group_tags`, `inherited_resource_group_tags`, `enable_diagnostics`, `diagnostic_metrics`, `enable_autoscale`. Review those inputs to see which optional components a deployment creates.

The module accepts 49 input(s), with 2 required.
It returns 21 output(s), including `id`, `name`, `sku_name`, `location`, `resource_group_name`, `os_type`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
