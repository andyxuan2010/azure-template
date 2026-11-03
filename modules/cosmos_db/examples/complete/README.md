# Complete Cosmos DB Example

Creates a private, multi-region SQL API account with automatic failover, zone redundancy, continuous backup, an autoscale database, a partitioned container, diagnostics, and optional operator RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-data-prod" `
  -var="private_endpoint_subnet_id=/subscriptions/.../virtualNetworks/vnet-data-prod/subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.documents.azure.com" `
  -var="log_analytics_workspace_id=/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
```

Verify regional capacity and zone support, failover priorities, backup requirements, throughput limits, private DNS, and application retry behavior before apply. Multi-region capacity and diagnostic ingestion materially affect cost.
