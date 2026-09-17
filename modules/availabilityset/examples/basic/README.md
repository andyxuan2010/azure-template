# Basic Availability Set Example

Creates a managed Availability Set with two fault domains and five update domains in an existing resource group.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-payments-dev"
```

Applying this example creates an Availability Set but no virtual machines. Confirm the region's supported fault-domain count, then pass `availability_set_id` to compatible VM resources.
