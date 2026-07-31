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
