# Complete Private Logic App Standard Example

Creates a Logic App Standard host with system-assigned identity, VNet integration, route-all, a separate inbound private endpoint, private DNS, diagnostics, and optional group RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

The environment values must provide the existing plan, storage account, delegated integration subnet, private endpoint subnet, DNS zone, and Log Analytics workspace. Storage endpoints also need compatible private routing and DNS. Applying creates billable Logic App, private endpoint, diagnostic, and optional RBAC resources.
