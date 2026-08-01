# Windows .NET Function App Example

Creates a private-by-default Windows Function App for .NET 8 isolated on an existing Windows App Service Plan. The storage connection string is referenced through an existing Key Vault secret.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-billing-prod" `
  -var="service_plan_id=/subscriptions/.../serverfarms/asp-billing-prod" `
  -var="storage_key_vault_secret_id=https://kv-example.vault.azure.net/secrets/function-storage/<version>"
```

The Function identity must be able to resolve the Key Vault reference. Applying creates a billable Function App.
