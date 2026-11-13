# Databricks Unity Catalog Access Connector Example

Creates a Premium workspace and system-assigned Databricks access connector, enables the managed-storage firewall integration, and grants the connector Blob Data Contributor on an existing external Storage Account.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-data-prod" `
  -var="external_storage_account_id=/subscriptions/.../providers/Microsoft.Storage/storageAccounts/stlakeprod"
```

This example creates only the Azure access connector and role assignment. Configure the storage credential, external location, catalog, schemas, and grants through a separate Databricks data-plane layer. Review whether Blob Data Contributor is narrower than necessary for your design.

## Cost and risk

- The Premium workspace is billable by Databricks usage (DBUs for compute you run later); the workspace itself runs no clusters here. Its managed storage account is billed per GB stored plus operations.
- The access connector and the role assignment are free. Costs of the external Storage Account (capacity, transactions) belong to that account, not to this example.
- Risk: `Storage Blob Data Contributor` gives the connector's managed identity read, write and delete on all blobs at the assigned scope, so scope it narrowly. `default_storage_firewall_enabled = true` and `public_network_access_enabled = false` change how the managed storage and workspace are reached; the storage firewall setting is applied at workspace level and is replacement-sensitive. Deleting the connector breaks any Unity Catalog storage credential that references it.
