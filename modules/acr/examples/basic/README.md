# Basic Azure Container Registry Example

Creates a Standard registry with administrative credentials, anonymous pull, and public network access disabled.

This example intentionally does not create a private endpoint. Add private connectivity before using this pattern for a workload that must access the registry.

## Usage

```powershell
terraform init
terraform validate
terraform plan -var="resource_group_name=rg-platform-dev"
```

The `prod` provider alias currently uses the same Azure context as the default provider. Configure that alias with the shared-network subscription when lookups cross subscription boundaries.
