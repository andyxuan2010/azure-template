# Private Endpoint Architecture

```text
consumer workload
       |
       v
Private Endpoint NIC ---- endpoint subnet
       |
       v
private service connection ---- target PaaS subresource
       |
       v
Private DNS zone group ---- existing Private DNS zone
```

## Provider Boundary

The default `azurerm` provider creates the Private Endpoint in the workload subscription. `azurerm.prod` is used only for optional subnet and Private DNS name lookups, allowing shared network resources to live in a connectivity subscription.

Passing direct resource IDs avoids lookup ambiguity and remains the preferred same-state composition path.

## Network Boundary

A Private Endpoint supplies a private NIC for inbound access to a specific service subresource. It does not disable the service public endpoint by itself. Public network access must be controlled on the target service.

The endpoint subnet, NSG behavior, routing, address capacity, and name resolution must be designed together.

## DNS Boundary

The optional zone group connects the endpoint to existing Private DNS zones. Those zones must be linked to every VNet that needs resolution, and hybrid clients require a forwarding path through Private Resolver or approved DNS infrastructure.

## Ownership and Sequencing

1. Create the resource group, VNet, endpoint subnet, and DNS zones.
2. Link the DNS zones to the required VNets.
3. Create the target PaaS resource.
4. Create the Private Endpoint.
5. Approve a manual connection when applicable.
6. Validate DNS resolution and application connectivity before disabling public access.

Use a single Terraform owner for each endpoint and DNS zone group.
