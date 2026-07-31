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
