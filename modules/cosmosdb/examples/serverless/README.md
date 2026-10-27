# Serverless Cosmos DB Example

Creates a single-region serverless SQL API account with one database and a TTL-enabled events container. Public network access and local authentication remain disabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-events-sbx"
```

Serverless has a distinct regional, performance, and billing model. Do not add provisioned throughput, autoscale throughput, multiple regions, or an account throughput limit to this scenario. Add approved private connectivity and Entra data-plane role assignments before application use.

## Cost and risk

- Serverless Cosmos DB bills per request unit consumed and per GB of storage, with no charge for provisioned throughput when idle; backups add cost according to the backup policy of the account. The 30-day default TTL on the events container limits storage growth.
- The serverless capability cannot be added to or removed from an existing account, so changing it forces replacement and data loss. Serverless is limited to a single region.
- Public network access and key authentication are disabled, so nothing can connect until a private endpoint and Entra data-plane roles exist. The account name is globally unique, and account creation and deletion can be slow.
