# Basic Azure AI Search Example

Creates a Standard Azure AI Search service with a system-assigned identity, public access disabled, and local key authentication disabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-search-dev"
```

The service name must be globally unique. This secure baseline has no private endpoint; add private connectivity or another approved network design before expecting workloads to connect. Search capacity is billable when applied.
