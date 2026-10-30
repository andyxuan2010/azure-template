# Azure Load Balancer Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["loadbalancer module"]
  Module --> R1["azurerm_lb"]
  Module --> R2["azurerm_lb_backend_address_pool"]
  Module --> R3["azurerm_lb_probe"]
  Module --> R4["azurerm_lb_rule"]
  Module --> R5["azurerm_lb_outbound_rule"]
```

The loadbalancer module declares 5 managed resource type(s), including `azurerm_lb`, `azurerm_lb_backend_address_pool`, `azurerm_lb_probe`, `azurerm_lb_rule`, `azurerm_lb_outbound_rule`.

Resources that use `count` or `for_each` are gated by inputs such as `inherit_resource_group_tags`, `inherited_resource_group_tags`, `frontend_ip_configurations`, `backend_address_pools`, `probes`, `lb_rules`. Review those inputs to see which optional components a deployment creates.

The module accepts 16 input(s), with 3 required.
It returns 9 output(s), including `id`, `name`, `frontend_ip_configurations`, `backend_address_pool_ids`, `probe_ids`, `rule_ids`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
