# Complete Private Azure OpenAI Example

Creates a private Azure OpenAI account with caller-selected model deployments, deny-by-default network ACLs, private DNS, diagnostics, managed identity, and optional group RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

The variable file must contain model names, versions, SKUs, and capacities supported by the selected region and available quota. Verify private DNS, network routes, role scopes, content-safety governance, and cost before apply.
