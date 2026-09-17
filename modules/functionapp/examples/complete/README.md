# Complete Private Function App Example

Creates a Linux Function App that uses managed identity for Function storage, regional VNet integration, a private endpoint with DNS, diagnostics, and optional group RBAC.

The root composition must grant the Function identity the required storage data roles. It must also provide separate integration and private endpoint subnets and working private DNS.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="service_plan_id=/subscriptions/.../serverfarms/asp-orders-prod" `
  -var="storage_account_name=stordersprod001" `
  -var="integration_subnet_id=/subscriptions/.../subnets/snet-functions" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.azurewebsites.net" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/law-platform-prod"
```

Applying creates billable Function App, private endpoint, diagnostic, and optional RBAC resources.
