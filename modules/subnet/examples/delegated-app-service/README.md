# App Service Delegated Subnet

Creates one subnet delegated to `Microsoft.Web/serverFarms` for App Service regional VNet integration.

Confirm the required subnet size and service-specific restrictions. Azure can block delegation changes while App Service resources remain attached.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
