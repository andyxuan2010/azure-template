# Complete Event Hubs Example

Creates a production-oriented Standard namespace with auto-inflate, identity-based Capture, Schema Registry, two consumer groups, private connectivity, diagnostics, and optional producer/consumer RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-streaming-prod" `
  -var="capture_storage_account_id=/subscriptions/.../providers/Microsoft.Storage/storageAccounts/stcaptureprod" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.servicebus.windows.net" `
  -var="log_analytics_workspace_id=/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
```

Create the Capture container and grant the namespace identity Blob data access before apply. Review partition count, throughput growth, retention, private DNS, consumer checkpointing, and diagnostic cost.
