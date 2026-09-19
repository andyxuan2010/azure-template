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
