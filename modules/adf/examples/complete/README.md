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

## Cost and risk

- Billing is per activity run and per integration-runtime vCore-hour (default General compute, 8 cores, 15-minute time to live). The private endpoint is billed hourly plus per GB processed, the managed private endpoint to storage is a separate charge in the managed network, and Log Analytics ingestion for diagnostics is billed per GB.
- Public access is disabled, so authoring and monitoring need the private endpoint and DNS zone. The managed private endpoint to storage is created pending and must be approved on the storage account before pipelines can reach it.
- The managed virtual network cannot be toggled on an existing factory without replacement, and replacing the factory changes its system-assigned identity, which breaks role assignments made against the old one.
