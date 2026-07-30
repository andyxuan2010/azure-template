# Availability Set Module

Provision an Azure Availability Set with standardized naming, tag inheritance, managed-disk defaults, optional proximity placement group placement, and plan-only Terraform test coverage.

## Highlights

- Supports explicit names or generated names using `name_prefix`, `workload_name`, `location_code`, `app_env`, and `instance`.
- Defaults to managed Availability Sets for modern managed-disk VM deployments.
- Validates fault and update domain ranges before plan/apply.
- Optionally inherits tags from the target resource group while allowing caller tags to override.
- Supports proximity placement group association for latency-sensitive VM sets.

## Usage

```hcl
module "availabilityset" {
  source = "./modules/availabilityset"

  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"
  workload_name       = "platform"
  app_env             = "prod"
  instance            = "001"

  platform_fault_domain_count  = 2
  platform_update_domain_count = 5

  tags = {
    Owner = "CCOE"
  }
}
```

## Proximity Placement Group

```hcl
module "availabilityset" {
  source = "./modules/availabilityset"

  name                = "avail-app-cc-prod-001"
  resource_group_name = "rg-platform-prod"
  location            = "canadacentral"

  proximity_placement_group_id = "/subscriptions/<sub>/resourceGroups/<rg>/providers/Microsoft.Compute/proximityPlacementGroups/<name>"
}
```

## Notes

- Azure Availability Sets and Availability Zones are alternative VM placement models. Do not assign the same VM to both.
- Use `managed = true` for VMs that use managed disks.
- Platform fault domain support can vary by region. Confirm the target region supports the requested value before applying.
- Availability Sets do not create or attach VMs; pass the output `id` to VM modules or VM resources that should use it.

## Testing

Run validation and tests from the module directory:

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```
