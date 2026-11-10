# Complete Private Linux Web App Example

Demonstrates a production-oriented Linux Web App with:

- system-assigned managed identity;
- public access and basic publishing credentials disabled;
- separate outbound VNet integration and inbound private endpoint subnets;
- private DNS association and route-all outbound behavior;
- health checking, Application Insights, diagnostics, and production tags.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="app_service_plan_id=/subscriptions/.../serverfarms/asp-orders-prod" `
  -var="vnet_integration_subnet_id=/subscriptions/.../subnets/snet-app-integration" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.azurewebsites.net" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/log-platform-prod"
```

Applying creates billable App Service, Application Insights, private endpoint, and monitoring resources. Verify Premium plan support, separate subnet purposes, delegation, private DNS VNet links, routes, outbound dependencies, health endpoint behavior, and cleanup.
