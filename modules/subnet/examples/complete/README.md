# Complete Subnet Composition

Creates an application subnet associated with existing NSG/route controls and a dedicated private-endpoint subnet. Optional Microsoft Entra object IDs receive VNet-scoped RBAC.

Review the broad VNet roles, address plan, NSG rules, routes, and private endpoint policy requirements before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
