# Basic App Service Plan Example

Creates a single-worker Linux B1 App Service Plan for low-cost development workloads.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-dev"
```

Applying creates billable hosting capacity even without an attached application. Confirm region, quota, cost ownership, operating-system compatibility, and cleanup.
