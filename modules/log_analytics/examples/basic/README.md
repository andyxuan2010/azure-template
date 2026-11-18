# Basic Log Analytics Example

Creates a PerGB2018 Log Analytics workspace with 90-day retention and local/shared-key authentication disabled. Public ingestion and query endpoints remain enabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-dev"
```

Applying creates a usage-billed workspace. Confirm retention, access, ingestion ownership, data residency, and cost controls first.
