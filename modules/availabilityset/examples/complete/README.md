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
