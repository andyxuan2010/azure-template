# Complete Azure Container Registry Example

Demonstrates a production-oriented Premium registry with:

- public access and administrative credentials disabled;
- a system-assigned managed identity;
- Premium security and retention controls;
- zone redundancy and geo-replication;
- a private endpoint and private DNS association;
- Log Analytics diagnostics.

## Usage

Supply existing dependency IDs and a globally unique registry name:

```powershell
terraform init
terraform validate
terraform plan `
  -var="resource_group_name=rg-platform-prod" `
  -var="registry_name=contosoplatformprod001" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.azurecr.io" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/log-platform-prod"
```

Confirm that the selected regions support zone redundancy and that the Terraform identity can create private endpoints, diagnostic settings, and role assignments.
