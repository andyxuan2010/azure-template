# Basic Logic App Standard Example

Creates a private-by-default Logic App Standard host on existing Workflow Standard compute and storage, with a system-assigned identity. It does not deploy workflows or API connections.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="service_plan_id=/subscriptions/.../serverfarms/asp-orders-dev" `
  -var="storage_account_name=storderslogicdev" `
  -var="storage_account_resource_group_name=rg-orders-dev"
```

The module reads the storage account access key into Terraform state. Public access is disabled and no private endpoint is created, so complete private connectivity before expecting the host to be reachable. Applying creates a billable Logic App Standard resource.
