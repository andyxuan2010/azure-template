# Complete Custom Role and Assignment

Creates the FortiGate Route Updater custom role and assigns it to an existing managed identity by composing `customrole` with `roleassignments`.

Supply an existing resource group ID for `role_definition_scope`, a resource group or route table ID for `assignment_scope`, and the managed identity's **principal/object ID** for `managed_identity_principal_id`. The principal is created separately. The principal ID is not its client ID or Azure resource ID.

The role grants route table read, route read, and route create/update. It does not grant route deletion, route table changes, or RBAC management. Prefer assigning at the specific route table scope when only one table should be managed.

The Terraform identity needs permission to manage custom role definitions at the definition scope and create role assignments at the assignment scope. AzureAD is a required provider of `roleassignments`, though this example supplies the principal ID directly and does not perform group-name lookup.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var='role_definition_scope=/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>' `
  -var='assignment_scope=/subscriptions/<subscription-id>/resourceGroups/<resource-group-name>/providers/Microsoft.Network/routeTables/<route-table-name>' `
  -var='managed_identity_principal_id=<managed-identity-object-id>'
```

Plan is read-only. Applying creates the role definition and the role assignment. Azure RBAC changes can take time to propagate.

## Cost and risk

- Role definitions and role assignments are free, so nothing here is billed.
- The assignment gives route write permission to the managed identity at the route table scope, so a wrong principal ID or scope grants that access to the wrong place. If the role definition is replaced, its ID changes and the assignment is recreated. The role cannot be deleted while assignments reference it, and RBAC propagation can delay access for several minutes.
