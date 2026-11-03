# Basic Linux Web App Example

Creates a Linux Web App on an existing Linux App Service Plan with Python 3.12, HTTPS/TLS controls, disabled FTPS, and a system-assigned managed identity.

Public network access remains enabled, but the module's default unmatched IP action is `Deny` and this example defines no allow rules. The app is not reachable until reviewed IP restrictions or the private networking pattern are added. No application code is deployed.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-dev" `
  -var="app_service_plan_id=/subscriptions/.../serverfarms/asp-orders-dev"
```

Applying creates a billable Web App on the supplied plan. Confirm global name uniqueness, plan OS compatibility, access policy, application deployment ownership, and cleanup.
