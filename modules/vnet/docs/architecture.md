# Virtual Network Architecture

## Scope

The module owns one VNet and optionally its initial subnets, VNet-scoped role assignments, DDoS plan attachment, and diagnostics. The caller owns peerings, gateways, firewalls, NSGs, routes, private endpoints, DNS zones, and dependent workloads.

## Resource Flow

```text
existing resource group
         |
         v
        VNet -------- existing DDoS plan
      /  |  \
subnets RBAC diagnostics -------- Log Analytics
```

The VNet is created before all optional subnets. Microsoft Entra groups are resolved only when display names are supplied. Explicit object IDs avoid those lookups.

## Address and Lifecycle Boundaries

The module validates that VNet and subnet CIDRs are syntactically valid and network-aligned. It does not provide IP address management or compare ranges with other networks. Address planning, overlap control, routing, and DNS design are external responsibilities.

Subnet map keys become subnet names and Terraform addresses. Moving established subnet management between this module and the separate `subnet` module requires explicit state moves. Address, delegation, policy, or DNS changes can disrupt dependent resources.

## Operational Boundaries

Diagnostics are optional and send selected VNet categories to an existing Log Analytics workspace. NSG flow logs and Network Watcher resources are not part of this module. DDoS attachment requires an existing eligible plan and appropriate subscription/region support.
