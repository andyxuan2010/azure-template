# Windows Web App Example

Creates a 64-bit Windows Web App with the .NET 8 application stack and a system-assigned managed identity on an existing Windows App Service Plan.

The module's default unmatched IP action is `Deny`; add reviewed ingress rules or private connectivity before expecting the application endpoint to be reachable.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="app_service_plan_id=/subscriptions/.../serverfarms/asp-orders-windows-dev"
```

Applying creates a billable Web App. Confirm that the supplied plan uses Windows, the selected runtime is supported in the region, application deployment ownership is clear, and cleanup is planned.
