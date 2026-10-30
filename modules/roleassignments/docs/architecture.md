# Azure Role Assignments Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["roleassignments module"]
  Module --> R1["azurerm_role_assignment"]
```

The roleassignments module declares 1 managed resource type(s), including `azurerm_role_assignment`.

The module accepts 1 input(s), with 0 required.
It returns 1 output(s), including `role_assignment_ids`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
