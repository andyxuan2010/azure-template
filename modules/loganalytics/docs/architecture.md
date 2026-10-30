# Azure Log Analytics Workspace Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["loganalytics module"]
  Module --> R1["azurerm_log_analytics_workspace"]
```

The loganalytics module declares 1 managed resource type(s), including `azurerm_log_analytics_workspace`.

Resources that use `count` or `for_each` are gated by inputs such as `inherit_resource_group_tags`, `inherited_resource_group_tags`, `identity`, `timeouts`. Review those inputs to see which optional components a deployment creates.

The module accepts 22 input(s), with 2 required.
It returns 9 output(s), including `id`, `name`, `workspace_id`, `primary_shared_key`, `secondary_shared_key`, `identity`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
