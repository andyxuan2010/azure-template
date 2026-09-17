# Serverless Cosmos DB Example

Creates a single-region serverless SQL API account with one database and a TTL-enabled events container. Public network access and local authentication remain disabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-events-sbx"
```

Serverless has a distinct regional, performance, and billing model. Do not add provisioned throughput, autoscale throughput, multiple regions, or an account throughput limit to this scenario. Add approved private connectivity and Entra data-plane role assignments before application use.
