# New Subscription Alias

Creates only the subscription alias. It deliberately disables management-group association, provider registration, and resource-group bootstrap.

This is stage one of a two-stage workflow. After apply, configure a separate AzureRM provider/state with `subscription_id` and run the existing-subscription bootstrap pattern. Subscription creation is governance-sensitive and may affect billing.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
