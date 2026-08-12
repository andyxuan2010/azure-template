# Governed Private-Access Log Analytics Example

Creates a capacity-reservation workspace with a daily quota, 90-day retention, system-assigned identity, default Data Collection Rule, disabled local auth, and disabled public ingestion/query endpoints.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="data_collection_rule_id=/subscriptions/.../dataCollectionRules/dcr-platform-prod"
```

Do not apply until Azure Monitor Private Link Scope, DNS, Data Collection Endpoints, agent associations, and private query access are working. Capacity reservations are a material cost commitment.
