# Azure Network Security Group Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["nsg module"]
  Module --> R1["azurerm_network_security_group"]
  Module --> R2["azurerm_subnet_network_security_group_association"]
  Module --> R3["azurerm_network_interface_security_group_association"]
```

The nsg module declares 3 managed resource type(s), including `azurerm_network_security_group`, `azurerm_subnet_network_security_group_association`, `azurerm_network_interface_security_group_association`.

Resources that use `count` or `for_each` are gated by inputs such as `inherit_resource_group_tags`, `inherited_resource_group_tags`, `security_rules`, `subnet_ids`, `subnet_associations`, `network_interface_ids`. Review those inputs to see which optional components a deployment creates.

The module accepts 14 input(s), with 2 required.
It returns 8 output(s), including `id`, `name`, `security_rule_names`, `subnet_association_ids`, `network_interface_association_ids`, `tags`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
