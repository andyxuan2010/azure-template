# Linux VM Module

Provision Linux virtual machines with bootstrap, RBAC, networking, and optional diagnostics.

## Overview

- Providers: `azurerm` `4.65.0`
- Inputs: 38
- Outputs: 17
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Best Practices Implemented

- Standardized variable naming across the module (e.g., `vm_name` instead of `app_vm`, `admin_username` instead of `azure-user`, and `resource_group_name` instead of `app_rg`).
- Explicitly configured `boot_diagnostics {}` block to use Managed Boot Diagnostics without an explicit storage account.
- Consistent application of System-Assigned Managed Identities.

## Features

- Creates managed resources including `azurerm_linux_virtual_machine`, `azurerm_managed_disk`, `azurerm_network_interface`, `azurerm_network_interface_security_group_association`, `azurerm_network_security_group`.
- Spreads multi-VM deployments across availability zones by default when `vm_count > 1`, using round-robin placement from `availability_zones`.
- Supports a system-assigned managed identity on each Linux VM, enabled by default and optionally disabled with `enable_system_assigned_identity`.
- Supports optional Entra SSH login, including `Virtual Machine Administrator Login` for `app_admin_group` and `Virtual Machine User Login` for `app_user_group` when enabled.
- Supports optional Azure Spot instances with configurable eviction policy and maximum bid price.
- Grants `Reader` on the VM resource group to both `app_admin_group` and `app_user_group`. If matching assignments already exist at that exact scope, import them from the root module or with `terraform import` before apply.
- Supports optional Bastion access RBAC when `bastion_resource_name` is set:
  both `app_admin_group` and `app_user_group` get `Reader` on the Bastion resource group, and both groups also get `Network Contributor` on the Bastion host itself. If matching assignments already exist at those exact scopes, import them from the root module or with `terraform import` before apply.
- Supports an optional storage-backed Linux VM localization extension that best-effort downloads an OS script and a VM-specific script by hostname from the shared IaC storage account.
- Supports optional Terraform-managed upload of hostname-specific localization scripts to the shared IaC storage container without changing the global OS-level script flow.
- Supports resource-level RBAC inputs for administrative and read-only access patterns.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

For the authentication models and supported login methods, see [AUTHENTICATION.md](AUTHENTICATION.md).

For an operations-oriented summary of features, security, access, bootstrap, localization, logging, and improvement ideas, see [LINUX_VM.md](LINUX_VM.md).

## Bootstrap Logic

This module can bootstrap a Linux VM in three places:

1. `custom_data` / cloud-init via `scripts/init.sh`
2. `post_init_script`
3. merged localization script from the storage container when `enable_linux_vm_extension = true`

The execution logic is:

- `init.sh` is the base bootstrap and runs first in the VM `custom_data` / cloud-init path.
- If `post_init_script` is provided, Terraform appends it after `init.sh`, so it runs in the same first-boot flow.
- If the localization extension is enabled, the VM later runs a separate guest-side localization runner that tries to merge the OS-level localization script and the VM-specific localization script from the blob container.
- When `localization_vm_script_content` is used, Terraform uploads those managed VM-specific blobs before the localization extension runs.
- When managed VM-specific blob content changes, Terraform also updates the extension `timestamp` setting so the Azure `CustomScript` extension can rerun with the new script content.
- When an extra data disk is enabled through `data_disk_size_gb`, Terraform also waits for the VM data-disk attachment before the localization extension runs.
- If one localization script is missing or empty, the runner uses the other one when available.
- If both localization scripts are missing or empty, the localization phase exits successfully and skips.

Operational guidance:

- Package installation is recommended in `init.sh` or `post_init_script`.
- Package installation is not recommended in the merged localization script because it can overlap with or conflict with package-manager work from the first two bootstrap paths.
- A valid consumer pattern is to install a workload in `post_init_script` and use the later localization phase for post-bootstrap storage work such as attaching, mounting, or migrating persistent application data onto an extra managed disk.
- When consumers intentionally install first and mount later, the VM-specific localization script should stop any running service, copy existing application data to the new disk, mount the disk at the final path, and then restart the service only if it was active before migration.
- If package installation is still done in localization scripts, add explicit wait/retry handling for package-manager locks and long-running bootstrap overlap.

## Basic Usage

```hcl
module "linuxvm" {
  source = "./modules/linuxvm"

  resource_group_name = "<resource_group_name>"
  subnet_name = "<subnet_name>"
  vm_name = "<vm_name>"
  vnet_name = "<vnet_name>"
  vnet_resource_group_name = "<vnet_resource_group_name>"
  # vnet_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.Network/virtualNetworks/<vnet-name>"
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  iac_st = "<iac_st>"

  admin_username = "azureadmin"
  admin_password = var.linux_vm_admin_password
  admin_ssh_key  = var.linux_vm_admin_ssh_public_key
}
```

Credential precedence:

- direct module inputs `admin_username`, `admin_password`, and `admin_ssh_key` win when set
- otherwise the module reads `admin_username_secret_name`, `admin_password_secret_name`, and `admin_ssh_key_secret_name` from `admin_credentials_key_vault_id`
- if neither direct input nor Key Vault value is available, the module uses its built-in defaults

## Key Inputs

- `resource_group_name`: Target resource group name for the Linux VM resources. `string` (required)
- `subnet_name`: Existing subnet name used for the VM NICs. `string` (required)
- `vm_name`: Base Linux VM name. Environment suffixes are appended by the module. `string` (required)
- `vnet_name`: Existing virtual network name used for the VM NICs when `vnet_id` is not provided. `string` (required when `vnet_id` is empty)
- `vnet_resource_group_name`: Resource group containing the target virtual network when `vnet_id` is not provided. `string` (required when `vnet_id` is empty)
- `vnet_id`: Optional virtual network resource ID override used to resolve the subnet without a separate VNet lookup. `string` (default: `""`)
- `admin_username`: Optional admin username override. When omitted, the module falls back to Key Vault and then to the built-in default `azureadmin`. `string` (default: `null`)
- `admin_password`: Optional admin password override. When omitted, the module falls back to Key Vault and then to the module default. A non-empty effective password is still required unless `disable_password_authentication = true`. `string` (default: `null`, sensitive)
- `admin_ssh_key`: Optional admin SSH public key override. When omitted, the module falls back to Key Vault and then to the module default. A non-empty effective SSH key is still required. `string` (default: `null`, sensitive)
- `admin_credentials_key_vault_id`: Optional Key Vault resource ID for Linux VM admin credentials. When omitted, the module falls back to the shared IaC Key Vault referenced by `iac_kv_id`. `string` (default: `""`)
- `admin_username_secret_name`: Key Vault secret name for the admin username fallback. `string` (default: `"azure-user"`)
- `admin_password_secret_name`: Key Vault secret name for the admin password fallback. `string` (default: `"azure-password"`)
- `admin_ssh_key_secret_name`: Key Vault secret name for the admin SSH public key fallback. `string` (default: `"azureadmin-pubkey"`)
- `iac_kv`: Shared Key Vault name containing Linux VM secrets. `string` (required)
- `iac_rg`: Resource group containing the shared IaC storage account and Key Vault. `string` (required)
- `iac_st`: Shared storage account name containing bootstrap scripts. `string` (required)
- `app_admin_group`: Optional app admin group principal IDs granted Contributor on each VM resource, Contributor on each module-created NIC, and sudo/admin access inside the guest OS for the domain-join path. Empty strings are ignored. These groups also get `Reader` on the VM resource group. When Entra SSH login is enabled, they also get `Virtual Machine Administrator Login`. When a Bastion host is configured, they also get `Reader` on the Bastion resource group and `Network Contributor` on the Bastion host. `list(string)` (default: [])
- `app_user_group`: Optional app user group principal IDs granted Reader on each VM resource and standard SSH access inside the guest OS for the domain-join path. Empty strings are ignored. These groups also get `Reader` on the VM resource group. When Entra SSH login is enabled, they also get `Virtual Machine User Login`. When a Bastion host is configured, they also get `Reader` on the Bastion resource group and `Network Contributor` on the Bastion host. `list(string)` (default: [])
- `bastion_resource_name`: Optional Bastion host name used for `Network Contributor` role assignments for both `app_admin_group` and `app_user_group`. If matching role assignments already exist at the Bastion host scope, import them from the root module or with `terraform import` before apply. Set to `null` or `""` to skip Bastion RBAC. `string` (default: `bas-net-cc-prd`)
- `bastion_resource_group_name`: Resource group containing the Bastion host referenced by `bastion_resource_name`. `string` (default: `rg-ba-eus-prod-hub-network`)
- `post_init_script`: Optional inline bash content appended after the base `init.sh` bootstrap in the same `custom_data` flow. `string` (default: `""`)
- `enable_entra_ssh_login`: Whether to enable the Entra SSH login VM extension. `bool` (default: `false`)
- `enable_linux_vm_extension`: Whether to enable the optional storage-backed localization `CustomScript` extension. `bool` (default: `false`)
- `enable_system_assigned_identity`: Whether to enable a system-assigned managed identity on the Linux VMs. `bool` (default: `true`)
- `enable_zone_spread`: Whether to spread multi-VM deployments across availability zones by default. When enabled and `vm_count > 1`, the module assigns zones in round-robin order from `availability_zones`. `bool` (default: `true`)
- `availability_zones`: Availability zones used for round-robin placement when `enable_zone_spread = true` and `vm_count > 1`. `list(string)` (default: `["1", "2", "3"]`)
- `enable_spot_instance`: Whether to create the Linux VMs as Azure Spot instances. `bool` (default: `false`)
- `spot_eviction_policy`: Eviction policy for Spot Linux VMs. Used only when `enable_spot_instance = true`. Valid values are `Deallocate` or `Delete`. `string` (default: `Deallocate`)
- `spot_max_bid_price`: Maximum hourly price for Spot Linux VMs. Used only when `enable_spot_instance = true`. Set to `-1` to pay up to the current on-demand price. `number` (default: `-1`)
- `enable_domain_join`: Whether to join the Linux VM to traditional Active Directory during bootstrap. `bool` (default: `false`)
- `localization_container_name`: Blob container name used by the optional localization extension. `string` (default: `localization`)
- `localization_os_script_name`: Optional OS-level localization script blob name used by the localization extension. When empty, missing in storage, or empty after download, the extension skips it. `string` (default: `ubuntu.sh`)
- `localization_vm_script_content`: Optional map of hostname-specific localization blob content keyed by blob name, for example `{ "myvm001.sh" = file("${path.module}/scripts/myvm001.sh") }`. When provided, Terraform uploads those blobs to the localization container and updates them on future applies when content changes. `map(string)` (default: `{}`)

Localization upload note:

- The localization container is only looked up when the localization extension is enabled or when `localization_vm_script_content` contains at least one blob.
- `localization_vm_script_content` is marked sensitive because the values contain script content.
- The blob names remain the resource instance keys, so choose stable keys such as `myvm001.sh`.

Group input guidance:

- `app_admin_group` and `app_user_group` are intended for Microsoft Entra group principal IDs.
- Empty strings are ignored, so `[]`, `null`, or `[""]` skips the related group RBAC.
- User object IDs are not a supported replacement for these group inputs.
- VM resource group `Reader`, Bastion resource group `Reader`, and Bastion `Network Contributor` RBAC use the same resolved group principal IDs as the VM RBAC and Entra SSH login paths.
- Existing matching `Reader` assignments on the VM resource group and Bastion resource group are detected only when the existing assignment scope exactly matches that resource group. Child-resource assignments do not satisfy the resource-group Reader path.
- When the Bastion host already has the required `Network Contributor` assignment for a resolved principal at the Bastion host scope, import that assignment from the root module or with `terraform import` before apply to avoid duplicate-create conflicts.
- When `enable_zone_spread = true` and `vm_count > 1`, the module assigns VM and optional managed data-disk zones in round-robin order across `availability_zones`.

## Notable Outputs

- `entra_ssh_login_extension_ids`: List of Entra SSH login VM extension IDs, if enabled.
- `linux_vm_extension_ids`: List of localization CustomScript VM extension IDs, if enabled.
- `computer_name`: List of Linux VM computer names.
- `id`: List of Linux virtual machine IDs.
- `managed_disk_ids`: List of managed data disk IDs.
- `managed_identity_principal_ids`: List of system-assigned managed identity principal IDs. Returns an empty list when system-assigned identity is disabled.
- `name`: List of Linux virtual machine names.
- `network_interface_ids`: List of network interface IDs.
- `network_interface_names`: List of network interface names.
- `network_security_group_ids`: List of network security group IDs created for public networking, if enabled.
- `network_security_group_names`: List of network security group names created for public networking, if enabled.
- `private_ip`: List of private IP addresses assigned to the VM NICs.
- `private_ip_by_vm_name`: Map of Linux VM name to private IP address.
- `public_ip`: List of public IP addresses, if public networking is enabled.
- `public_ip_ids`: List of public IP resource IDs, if public networking is enabled.
- `role_assignment_ids`: Role assignment IDs created for VM resource RBAC, NIC resource RBAC, optional Entra VM login RBAC, Storage Blob Data Contributor, optional localization Storage Blob Data Reader, Key Vault Reader, and Key Vault Secrets User.
- `tags`: The effective tags assigned to the Linux VM resources.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
