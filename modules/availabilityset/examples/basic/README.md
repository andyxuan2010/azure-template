# Basic Availability Set Example

Creates a managed Availability Set with two fault domains and five update domains in an existing resource group.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-payments-dev"
```

Applying this example creates an Availability Set but no virtual machines. Confirm the region's supported fault-domain count, then pass `availability_set_id` to compatible VM resources.

## Cost and risk

- An Availability Set is free; you pay only for the virtual machines placed in it, and this example creates none.
- Fault-domain and update-domain counts cannot be changed in place, so changing them replaces the set, and replacing a set that VMs use means recreating those VMs. A region may support fewer fault domains than the 2 requested.
