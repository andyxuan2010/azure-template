# Basic Linux Function App Example

Creates a private-by-default Linux Function App on an existing Linux App Service Plan and storage account. It configures Python 3.11 but does not deploy application code.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="service_plan_id=/subscriptions/.../serverfarms/asp-orders-dev" `
  -var="storage_account_name=stordersdev001" `
  -var="storage_account_access_key=<sensitive-value>"
```

The access key is stored in Terraform state. Prefer the managed-identity pattern in the complete example for production. Applying creates a billable Function App.
