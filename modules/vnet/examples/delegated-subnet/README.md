# VNet with App Service Delegation

Creates a VNet with one subnet delegated to `Microsoft.Web/serverFarms`.

Confirm the service-specific subnet size and restrictions before apply. Moving an established delegated subnet to another Terraform module requires an explicit state move.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: the virtual network and delegated subnet are free. No DDoS protection plan is set (the billable add-on here). Peerings, gateways and the App Service plan that uses the subnet are billed separately.
- Risk: `name` is random-suffixed when empty, so set it explicitly to avoid surprises. Changing `address_space` can fail while subnets or peerings depend on it, and the `Microsoft.Web/serverFarms` delegation reserves the subnet for App Service.
