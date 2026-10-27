# Basic Custom Role

Creates a custom control-plane role for reading route tables and reading or writing routes.

Provide an existing resource group ID as `scope`. The Terraform identity needs permission to create or update custom role definitions at that scope. Review the Azure operation names and assignable scope before applying in your environment.

```powershell
terraform init -backend=false
terraform validate
terraform plan -var='scope=/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>'
```

The plan is read-only. Applying creates an Azure RBAC role definition. Azure RBAC changes may take time to propagate. This example does not assign the role to a principal; see [complete](../complete/README.md) for the role definition plus assignment composition.

## Cost and risk

- Role definitions are free, so nothing here is billed.
- The role can read route tables and write routes but not delete them or manage RBAC, and it is only assignable at the supplied scope. Azure limits the number of custom role definitions per tenant, changing the name or scope can force replacement, and a role cannot be deleted while assignments reference it.
