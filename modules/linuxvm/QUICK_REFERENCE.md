# Linux VM Quick Reference

Purpose: Provision Linux virtual machines with bootstrap, RBAC, networking, and optional diagnostics.

## Required Inputs

- `app_rg`: `string`
- `app_snet`: `string`
- `app_vm`: `string`
- `azure-user`: `string`
- `azure-password`: `string`
- `azure-ssh-key`: `string`
- `iac_kv`: `string`
- `iac_rg`: `string`
- `iac_st`: `string`

## Common Optional Inputs

- `app_vnet`: `string`, required when `app_vnet_id` is empty
- `app_vnet_id`: `string`, optional virtual network resource ID override
- `app_vnet_rg`: `string`, required when `app_vnet_id` is empty
- `app_admin_group`: `list(string)`
- `app_user_group`: `list(string)`
- `bastion_resource_group_name`: `string`, defaults to `rg-ba-eus-prod-hub-network`
- `bastion_resource_name`: `string`, defaults to `bas-net-cc-prd`; set to `null` or empty to skip Bastion resource-group `Reader` and Bastion host `Network Contributor` RBAC, and import any pre-existing matching assignments from the root module or with `terraform import` before apply
- `common_tags`: `map(string)`
- `enable_domain_join`: `bool`, defaults to `false`
- `enable_entra_ssh_login`: `bool`, defaults to `false`
- `enable_linux_vm_extension`: `bool`, defaults to `false`
- `enable_system_assigned_identity`: `bool`, defaults to `true`
- `enable_zone_spread`: `bool`, defaults to `true`; when enabled and `app_vm_number > 1`, spreads VMs across availability zones in round-robin order
- `availability_zones`: `list(string)`, defaults to `["1", "2", "3"]`; used for round-robin zone placement of multi-VM deployments
- `localization_container_name`: `string`, defaults to `localization`
- `localization_os_script_name`: `string`, defaults to `ubuntu.sh`; skipped when empty, missing, or empty after download
- `localization_vm_script_content`: `map(string)`, defaults to `{}`; optionally uploads hostname-specific localization blobs such as `myvm001.sh` into the localization container during `terraform apply`
  Blob names are the visible Terraform instance keys; script contents remain sensitive.
  Managed blob-content changes also update the localization extension `timestamp` so the guest can rerun the latest VM-specific script.
- `post_init_script`: `string`, defaults to empty
- `rg_tags`: `map(string)`

## Bootstrap Guidance

- Prefer package installation in `scripts/init.sh` or `post_init_script`.
- Use the later localization phase for post-bootstrap customization and storage work.
- A valid consumer pattern is to install an application first and then use the VM-specific localization script to migrate its data onto an attached managed disk before final steady-state operation.

## Group Input Guidance

- `app_admin_group` and `app_user_group` are intended for group principal IDs.
- Empty strings are ignored, so `[]`, `null`, or `[""]` skips the related group RBAC.
- User object IDs are not supported as replacements for these group inputs.
- Both `app_admin_group` and `app_user_group` receive `Reader` on the VM resource group.
- When Bastion is configured, both groups also receive `Reader` on the Bastion resource group.
- When Bastion is configured, both groups also receive `Network Contributor` on the Bastion host.
- Existing matching `Reader` assignments on the VM resource group and Bastion resource group should be imported only when the assignment scope exactly matches that resource group.
- Existing matching `Network Contributor` assignments on the Bastion host should be imported only when the assignment scope exactly matches the Bastion host.
- Reader assignments on child resources under the resource group do not satisfy the resource-group Reader path.

## Primary Outputs

- `entra_ssh_login_extension_ids`
- `id`
- `managed_disk_ids`
- `managed_identity_principal_ids` - empty when system-assigned identity is disabled
- `name`
- `network_interface_ids`
- `private_ip`
- `public_ip`
- `role_assignment_ids`
- `tags`

## Test Commands

```powershell
terraform test
terraform test -filter='tests\live.tftest.hcl'
```
