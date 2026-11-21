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

## Cost and risk

- The Standard registry is billed per day for the SKU, plus storage above the included amount.
- Admin credentials and anonymous pull are enabled, which are weak controls; keep them off beyond a sandbox. With public network access disabled and no private endpoint, pushes and pulls fail from everywhere until you add private connectivity.
