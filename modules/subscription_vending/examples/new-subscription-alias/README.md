# New Subscription Alias

Creates only the subscription alias. It deliberately disables management-group association, provider registration, and resource-group bootstrap.

This is stage one of a two-stage workflow. After apply, configure a separate AzureRM provider/state with `subscription_id` and run the existing-subscription bootstrap pattern. Subscription creation is governance-sensitive and may affect billing.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: a new subscription is created under `billing_scope_id`. Holding it is free, but every resource later created in it bills to that billing scope.
- Risk: creating a subscription is hard to undo. Destroying `azurerm_subscription` cancels it rather than deleting it immediately, and the alias name may stay reserved. Creation needs billing-scope rights and can take several minutes. Treat the alias name and billing scope as permanent. Management group association is off, so the subscription lands in the tenant default group.
