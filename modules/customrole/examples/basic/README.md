# Basic Custom Role

Creates a custom control-plane role for reading route tables and reading or writing routes.

Provide an existing resource group ID as `scope`. The Terraform identity needs permission to create or update custom role definitions at that scope. Review the Azure operation names and assignable scope before applying in your environment.

```powershell
terraform init -backend=false
terraform validate
terraform plan -var='scope=/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>'
```

The plan is read-only. Applying creates an Azure RBAC role definition. Azure RBAC changes may take time to propagate. The example does not assign the role to a principal; use the `roleassignments` module separately.
