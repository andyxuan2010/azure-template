# Basic Cosmos DB Example

Creates a private-by-default SQL API account with Entra-oriented authentication, continuous backup, one autoscale database, and one partitioned container.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-data-dev"
```

The account name must be globally unique. This baseline disables public access but does not create a private endpoint, so add approved private connectivity before application use. Cosmos DB throughput is billable; confirm partition-key design and autoscale cost before apply.
