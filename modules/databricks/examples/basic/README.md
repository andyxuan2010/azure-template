# Basic Azure Databricks Example

Creates a Premium Azure Databricks workspace with public network access disabled and no optional network or data-plane resources.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-data-dev"
```

The illustrative workspace name must be globally unique. This private-by-default baseline does not yet provide VNet injection or a private endpoint; complete the approved connectivity design before expecting users or clusters to connect. Databricks workspace and compute usage are billable.
