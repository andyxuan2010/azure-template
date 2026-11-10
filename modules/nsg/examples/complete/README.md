# Complete Application NSG Example

Creates an NSG with reviewed inbound application/probe rules, an outbound Storage rule, and ownership of one subnet association.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="gateway_subnet_prefix=10.20.0.0/24" `
  -var="application_subnet_id=/subscriptions/.../subnets/snet-application"
```

Confirm the service tags, ports, source CIDR, effective routes, and association ownership. Applying or changing an NSG can immediately affect production connectivity.

## Cost and risk

- Cost: the network security group, its three rules and the subnet association are not billed.
- Risk: the NSG is bound to `application_subnet_id`, replacing any NSG already on that subnet, and takes effect on production traffic immediately. Azure default rules still apply after the custom rules, so VNet-internal traffic and outbound internet remain allowed because no deny rule is defined. Inbound priority 100 and 110 and outbound priority 100 are separate sets; inbound HTTPS is limited to `gateway_subnet_prefix` and the `AzureLoadBalancer` tag.
- Risk: renaming a rule key or changing priorities rewrites the inline rule set in place, so review the plan before applying to a live subnet.
