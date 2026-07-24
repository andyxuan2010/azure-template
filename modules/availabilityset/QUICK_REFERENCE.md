# Availability Set Quick Reference

Purpose: Create an Azure Availability Set for VM fault-domain and update-domain placement.

## Required Inputs

- `resource_group_name`: target resource group name.

## Common Inputs

- `location`: Azure region. Leave empty to read the resource group location.
- `name`: explicit Availability Set name. Leave empty for generated naming.
- `workload_name`, `app_env`, `location_code`, `instance`: generated naming controls.
- `platform_fault_domain_count`: defaults to `2`.
- `platform_update_domain_count`: defaults to `5`.
- `managed`: defaults to `true`.
- `proximity_placement_group_id`: optional PPG resource ID.
- `inherit_resource_group_tags`, `inherited_resource_group_tags`, `tags`: tag controls.

## Primary Outputs

- `id`, `name`, `resource_group_name`, `location`
- `platform_fault_domain_count`, `platform_update_domain_count`
- `managed`, `proximity_placement_group_id`
- `tags`

## Validation Commands

```powershell
terraform fmt -check -recursive
terraform validate
terraform test
```
