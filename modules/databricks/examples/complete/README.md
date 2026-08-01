# Complete Azure Databricks Example

Creates a production-oriented Premium workspace with secure cluster connectivity, VNet injection, private UI/API access, enhanced security monitoring, diagnostics, and optional Azure management-plane RBAC.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-data-prod" `
  -var="virtual_network_id=/subscriptions/.../virtualNetworks/vnet-data-prod" `
  -var="public_subnet_name=snet-databricks-public" `
  -var="private_subnet_name=snet-databricks-private" `
  -var="public_subnet_nsg_association_id=/subscriptions/.../networkSecurityGroups/nsg-dbx-public/subnets/snet-databricks-public" `
  -var="private_subnet_nsg_association_id=/subscriptions/.../networkSecurityGroups/nsg-dbx-private/subnets/snet-databricks-private" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.azuredatabricks.net" `
  -var="log_analytics_workspace_id=/subscriptions/.../providers/Microsoft.OperationalInsights/workspaces/log-platform-prod"
```

Validate subnet delegation, NSGs, routes, outbound access, private DNS, regional workspace capacity, and data-plane administration before apply. This example does not manage clusters or Unity Catalog.
