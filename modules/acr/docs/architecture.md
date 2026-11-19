# Azure Container Registry Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["acr module"]
  Module --> R1["random_string"]
  Module --> R2["azurerm_container_registry"]
  Module --> R3["azurerm_role_assignment"]
  Module --> R4["azurerm_private_endpoint"]
  Module --> R5["azurerm_monitor_diagnostic_setting"]
```

The acr module declares 5 managed resource type(s), including `random_string`, `azurerm_container_registry`, `azurerm_role_assignment`, `azurerm_private_endpoint`, `azurerm_monitor_diagnostic_setting`.

Resources that use `count` or `for_each` are gated by inputs such as `location`, `inherit_resource_group_tags`, `inherited_resource_group_tags`, `private_dns_zone_id`, `private_dns_zone_name`, `private_dns_zone_resource_group_name`. Review those inputs to see which optional components a deployment creates.

The module accepts 43 input(s), with 1 required.
It returns 17 output(s), including `id`, `name`, `location`, `login_server`, `admin_username`, `admin_password`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
