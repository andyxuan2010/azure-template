# Azure Files Mount Example

Creates a Linux Web App and mounts an existing Azure Files share at `/mnt/data`.

This compatibility pattern places a storage access key in App Service configuration and Terraform state. Prefer identity-based application access when a mounted file system is not required, and use an approved secret-injection and rotation process when it is.

The module's default unmatched IP action is `Deny`; add reviewed ingress rules or private connectivity when the application must be reachable.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="app_service_plan_id=/subscriptions/.../serverfarms/asp-orders-dev" `
  -var="storage_account_name=stordersdev" `
  -var="storage_share_name=orders" `
  -var="storage_access_key=<sensitive>"
```

Do not put real keys in shared shell history. Applying creates a billable Web App and stores the key in Terraform state; verify storage networking, key rotation, mount limits, backup, and cleanup.
