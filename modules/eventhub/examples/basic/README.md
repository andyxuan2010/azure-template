# Basic Event Hubs Example

Creates a private-by-default Standard namespace with one four-partition Event Hub and one consumer group. Public network access and SAS authentication remain disabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-streaming-dev"
```

The namespace name must be globally unique. Add private connectivity and grant producer/consumer Entra data-plane roles before application use. Capacity and retained messages are billable.
