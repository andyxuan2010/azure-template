# Storage Private DNS Lookup

Creates a Blob private endpoint while resolving the subnet and shared private DNS zone by name. `azurerm.prod` must target the subscription containing the private DNS zone.

Prefer direct IDs when dependencies are already outputs in the calling root. Confirm cross-subscription read access and existing VNet-to-zone links before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: the Standard `LRS` StorageV2 account is billed per GB stored plus per operation. The blob private endpoint is billed per hour and per GB of data processed. The private DNS zone is only looked up, so this example adds no zone charge.
- Risk: the plan fails if the existing subnet or the `privatelink.blob.core.windows.net` zone cannot be found. The endpoint consumes a private IP in that subnet. The account stays unreachable publicly (public access off, firewall `Deny`), so removing the endpoint cuts off clients that rely on it.
