# Complete Azure Data Factory Example

Demonstrates a production-oriented Data Factory with:

- public network access disabled;
- an ADF managed virtual network and Azure integration runtime;
- an ADF control-plane private endpoint and private DNS association;
- a managed private endpoint to Storage Blob;
- an environment global parameter;
- Log Analytics diagnostics.

## Usage

```powershell
terraform init
terraform validate
terraform plan `
  -var="resource_group_name=rg-data-prod" `
  -var="private_endpoint_subnet_id=/subscriptions/.../subnets/snet-private-endpoints" `
  -var="private_dns_zone_id=/subscriptions/.../privateDnsZones/privatelink.datafactory.azure.net" `
  -var="storage_account_id=/subscriptions/.../storageAccounts/stplatformprod" `
  -var="log_analytics_workspace_id=/subscriptions/.../workspaces/log-platform-prod"
```

The managed integration runtime must have a valid private DNS and network path to the storage target.
