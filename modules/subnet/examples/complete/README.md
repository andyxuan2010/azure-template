# Complete Subnet Composition

Creates an application subnet associated with existing NSG/route controls and a dedicated private-endpoint subnet. Optional Microsoft Entra object IDs receive VNet-scoped RBAC.

Review the broad VNet roles, address plan, NSG rules, routes, and private endpoint policy requirements before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: subnets, NSG and route table associations, and role assignments are free. The NSG and route table are referenced, not created.
- Risk: associating a route table can redirect traffic (for example to a firewall) and an NSG can block traffic on the application subnet as soon as it is applied. The module also grants roles to the supplied groups, so confirm them before apply. The private endpoint subnet sets network policies to `Disabled`, which changes how NSGs and routes apply to endpoints there.
