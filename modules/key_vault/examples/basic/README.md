# Basic Key Vault Example

Creates an RBAC-authorized Key Vault with public access disabled, deny-by-default network ACLs, and purge protection. No data-plane access or private endpoint is added.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-dev"
```

The example passes `azurerm.prod` because it is part of the module contract, although this scenario performs no shared-network lookup. Applying creates a billable, initially network-isolated vault. Purge protection is a long-lived lifecycle choice.
