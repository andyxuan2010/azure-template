# Complete Availability Set Example

Creates a production-oriented managed Availability Set with generated naming, explicit domain counts, custom timeouts, and an existing proximity placement group.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-latency-prod" `
  -var="proximity_placement_group_id=/subscriptions/.../providers/Microsoft.Compute/proximityPlacementGroups/ppg-latency-prod"
```

The proximity placement group and target resource group must use a compatible location. Confirm regional fault-domain support and coordinate replacement-sensitive placement changes with the VM owners.

## Cost and risk

- An Availability Set is free; billing comes only from the VMs placed in it. The proximity placement group is also free, but it constrains where VMs can be allocated.
- Fault-domain count, update-domain count and the proximity placement group are replacement-sensitive, and replacing the set means recreating its VMs. Colocation can cause allocation failures when capacity is tight, especially when new VM sizes are added later. The 30-minute create, update and delete timeouts bound long operations, and deletion fails while VMs still reference the set.
