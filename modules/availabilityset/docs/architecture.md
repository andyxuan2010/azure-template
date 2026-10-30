# Azure Availability Set Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["availabilityset module"]
  Module --> R1["azurerm_availability_set"]
```

The availabilityset module declares 1 managed resource type(s), including `azurerm_availability_set`.

Resources that use `count` or `for_each` are gated by inputs such as `timeouts`. Review those inputs to see which optional components a deployment creates.

The module accepts 17 input(s), with 1 required.
It returns 10 output(s), including `id`, `name`, `resource_group_name`, `location`, `location_code`, `platform_fault_domain_count`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
