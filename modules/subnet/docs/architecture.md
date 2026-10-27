# Subnet Architecture

## Scope

The module owns subnets inside an existing VNet plus optional NSG and route-table associations. It can also create VNet-scoped role assignments. The VNet, security controls, routes, private DNS, and workloads remain separate lifecycle units.

## Resource Flow

```text
existing VNet
    |
    +-- subnet["application"] -- optional NSG association
    |                         \- optional route association
    |
    +-- subnet["private-endpoints"]
    |
    \-- subnet["delegated"] ---- service delegation
```

`virtual_network_id` is used directly for RBAC when supplied; otherwise the module looks up the VNet by name and resource group. Supplying the ID avoids an unnecessary lookup and makes composition with the `vnet` module explicit.

## Address and Lifecycle Boundaries

The module validates CIDR syntax and host-bit alignment but cannot detect conflicts outside its input map. Address-space planning, overlap prevention, IP reservation, and capacity forecasting belong to the network design process.

Subnet names are Terraform map keys. Renaming a key or changing address prefixes can replace a subnet. Azure will reject destructive changes while dependent private endpoints, delegated services, NICs, or other resources remain attached.

## Security

The module does not create NSGs or routes. Association by resource ID keeps those policies independently reviewable. VNet-level Contributor and Reader grants are broader than subnet-only access and should be used deliberately.
