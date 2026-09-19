# Storage Private DNS Lookup

Creates a Blob private endpoint while resolving the subnet and shared private DNS zone by name. `azurerm.prod` must target the subscription containing the private DNS zone.

Prefer direct IDs when dependencies are already outputs in the calling root. Confirm cross-subscription read access and existing VNet-to-zone links before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
