# App Service Delegated Subnet

Creates one subnet delegated to `Microsoft.Web/serverFarms` for App Service regional VNet integration.

Confirm the required subnet size and service-specific restrictions. Azure can block delegation changes while App Service resources remain attached.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: the delegated subnet is free. The App Service plan that later uses it is billed by its SKU.
- Risk: delegation to `Microsoft.Web/serverFarms` reserves the subnet for App Service, so other resource types cannot be placed in it. Changing the delegation or prefix while a plan is integrated fails or forces subnet replacement.
