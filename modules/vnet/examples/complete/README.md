# Complete Virtual Network

Creates a VNet with application and private-endpoint subnets, optional custom DNS, Microsoft Entra group RBAC, inherited tags, and Log Analytics diagnostics.

Review address overlap, custom DNS reachability, broad VNet roles, subnet policy settings, and Log Analytics ingestion costs before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
