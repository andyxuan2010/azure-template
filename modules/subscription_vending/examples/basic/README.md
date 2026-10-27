# Existing Subscription Placement

Associates an existing subscription with a target management group. The AzureRM provider is explicitly configured for the subscription being governed.

Moving a subscription changes inherited policy and RBAC. Review the effective governance and secure an approval before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

- Billing: nothing billable is created. The module only associates an existing subscription with a management group and registers no providers.
- Risk: placing a subscription under `management_group_id` applies that group's inherited policy and RBAC to everything in it right away. The subscription itself is not created or deleted by this example, but destroying the association moves it out of the group.
