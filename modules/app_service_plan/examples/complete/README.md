# Complete Premium App Service Plan Example

Demonstrates production hosting capacity with a Linux P1v3 plan, three workers, zone balancing, Premium platform-managed automatic scaling, Log Analytics diagnostics, optional plan-scope group RBAC, and production tags.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/log-platform-prod"
```

Pass immutable group object IDs only when plan-scope Contributor or Reader access is required. Applying creates continuously billable Premium capacity; confirm regional zone support, quota, scaling behavior, workload OS compatibility, access scope, cost ownership, and cleanup.
