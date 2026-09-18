# Basic Managed Identity Example

Creates one user-assigned managed identity without federation or role assignments.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-dev"
```

Applying creates a managed identity but grants it no access. Attach the identity to a workload and manage least-privilege authorization in the appropriate owning configuration.
