# Complete Azure AI Search Example

Creates a private, production-oriented Search service with two replicas, two partitions, semantic ranking, managed identity, diagnostics, workload query RBAC, and a shared private-link request to content storage.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-search-prod" `
  -var="private_endpoint_subnet_id=/subscriptions/.../virtualNetworks/vnet-search-prod/subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.search.windows.net" `
  -var="content_storage_account_id=/subscriptions/.../providers/Microsoft.Storage/storageAccounts/stcontentprod" `
  -var="log_analytics_workspace_id=/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
```

Approve the shared private-link request on the target Storage Account after creation. Review SKU availability, replica/partition cost, Search SLA requirements, private DNS, and identity permissions before apply.
