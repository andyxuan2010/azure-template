# Azure Custom Role Definition Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["customrole module"]
  Module --> R1["azurerm_role_definition"]
```

The customrole module declares 1 managed resource type(s), including `azurerm_role_definition`.

The module accepts 9 input(s), with 4 required.
It returns 4 output(s), including `id`, `role_definition_id`, `role_definition_resource_id`, `name`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
