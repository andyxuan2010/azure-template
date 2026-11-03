# Basic Management Group Example

Creates one management group with a stable explicit ID and optional existing parent. It does not move subscriptions or create governance assignments.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="parent_management_group_id=/providers/Microsoft.Management/managementGroups/contoso-root"
```

This is a tenant-level operation. Use credentials with reviewed management-group permissions and inspect the full plan before apply.

## Cost and risk

- Free: management groups have no charge, and no subscriptions are moved in this example.
- Risk: this is a tenant-wide change. A new group inherits Azure Policy and RBAC from `parent_management_group_id` (or the tenant root group if empty), so parent assignments can apply immediately to anything later placed under it. If `name` is empty the module generates one with a random suffix. Management group tags are not an Azure feature: the example's `tags` do not appear on the group (they only feed module outputs). Deletion fails while the group has children or subscriptions, and the caller needs write permission at the parent scope.
