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

## Cost and risk

- The Premium workspace is billable by Databricks usage (DBUs consumed by compute you run, at a rate that depends on the Premium tier); the workspace resource itself does not run clusters, so an idle workspace from this example generates little Databricks charge.
- The workspace deploys a managed resource group with a managed storage account (`Standard_ZRS`, billed per GB stored plus operations) and, because `no_public_ip = true`, secure cluster connectivity; any outbound NAT or egress you provide for the delegated subnets is billed separately.
- Enhanced security and compliance (automatic cluster update and enhanced security monitoring) adds a Databricks surcharge on compute usage.
- The private endpoint is billed per hour plus per GB processed; the diagnostic setting bills Log Analytics ingestion and retention per GB. The optional Reader role assignment is free.
- Risk: `public_network_access_enabled = false` with `NoAzureDatabricksRules` means the workspace is unreachable without working private DNS, routing and NSG rules, so you can lock yourself out of the UI. VNet injection settings (virtual network, subnet names, `no_public_ip`) and the managed storage SKU are replacement-sensitive; changing them recreates the workspace and its data. Workspace creation and deletion can take many minutes, and deleting it removes the managed resource group.
