# VNet with App Service Delegation

Creates a VNet with one subnet delegated to `Microsoft.Web/serverFarms`.

Confirm the service-specific subnet size and restrictions before apply. Moving an established delegated subnet to another Terraform module requires an explicit state move.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
