# Windows VM Module

Provision Windows virtual machines with bootstrap, RBAC, SHIR integration, networking, and optional diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 46
- Outputs: 7
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_managed_disk`, `azurerm_network_interface`, `azurerm_network_interface_security_group_association`, `azurerm_network_security_group`, `azurerm_public_ip`.
- Grants `app_admin_group` admin RBAC and local administrator membership, and grants `app_user_group` user RBAC plus local Remote Desktop Users membership.
- Spreads multi-VM deployments across availability zones by default when `app_vm_number > 1`, using round-robin placement from `availability_zones`.
- Supports optional diagnostic settings to Log Analytics.
- Includes SHIR-related wiring for Data Factory scenarios.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

The module resolves administrator credentials in this order:

- Use `azure-user` and `azure-password` input values when they are non-empty.
- Otherwise fall back to the configured username and password secrets in the selected Key Vault.
- When `admin_credentials_key_vault_id` is empty, the module uses the shared IaC Key Vault resource ID derived from `iac_rg` and `iac_kv` for backward compatibility.

The module resolves domain join credentials the same way when `enable_domain_join = true` outside `sbx`:

- Use `domain_join_user` and `domain_join_password` input values when they are non-empty.
- Otherwise fall back to `domain_join_username_secret_name` and `domain_join_password_secret_name` in the selected Key Vault.
- When `admin_credentials_key_vault_id` is empty, the module uses the shared IaC Key Vault resource ID derived from `iac_rg` and `iac_kv`.

The shared IaC Key Vault, storage account, and `scripts` container are referenced from input values instead of Terraform data sources. This lets plans run before those shared resources are readable in the current Azure context, while still producing the expected Key Vault and Storage RBAC scopes and script blob URLs.

Resource tags are resolved by starting with the existing application resource group's tags, then overlaying `tags`, and finally the module `workload` tag. Later layers win when the same tag key appears more than once.

## SHIR Usage

Use `enable_shir = true` when the VM should bootstrap Self-Hosted Integration Runtime behavior. When SHIR is enabled:

- `enable_custom_script_extension` must also be `true`
- `adf_id` must be set so the VM identity can receive `Data Factory Contributor`

## Basic Usage

```hcl
module "winvm" {
  source = "./modules/winvm"

  app_rg = "<app_rg>"
  app_snet = "<app_snet>"
  app_vm = "<app_vm>"
  app_vnet = "<app_vnet>"
  app_vnet_rg = "<app_vnet_rg>"
  iac_rg = "<iac_rg>"
  windows_image_publisher = "MicrosoftWindowsServer"
  windows_image_offer     = "WindowsServer"
  windows_image_sku       = "2022-Datacenter"
  windows_image_version   = "latest"
  azure-user              = "azureadmin"
  azure-password          = "ChangeMe123!"

  tags = {
    Owner = "Platform"
  }
}
```

## Common Image Choices

Pick the image family based on the VM's purpose, then keep `windows_image_publisher`, `windows_image_offer`, `windows_image_sku`, and `windows_image_version` aligned to that family.

- General-purpose Windows Server VM:
  `windows_image_publisher = "MicrosoftWindowsServer"`, `windows_image_offer = "WindowsServer"`, `windows_image_sku = "2025-Datacenter"`
- Windows Server with Azure Edition features:
  `windows_image_publisher = "MicrosoftWindowsServer"`, `windows_image_offer = "WindowsServer"`, `windows_image_sku = "2022-datacenter-azure-edition"`
- Older compatibility target:
  `windows_image_publisher = "MicrosoftWindowsServer"`, `windows_image_offer = "WindowsServer"`, `windows_image_sku = "2019-Datacenter"`
- SQL Server preloaded on Windows:
  `windows_image_publisher = "MicrosoftSQLServer"`, `windows_image_offer = "sql2022-ws2022"`, `windows_image_sku = "standard-gen2"` or `enterprise-gen2`
- Azure Virtual Desktop / multi-session desktop:
  `windows_image_publisher = "MicrosoftWindowsDesktop"`, `windows_image_offer = "windows-11"`, `windows_image_sku = "win11-23h2-avd"`

Use `windows_image_version = "latest"` unless you need to pin to a specific marketplace version for repeatable builds or change control.

## Key Inputs

- `app_rg`: No description in `variables.tf`. `string` (required)
- `app_snet`: No description in `variables.tf`. `string` (required)
- `app_vm`: No description in `variables.tf`. `string` (required)
- `app_vnet`: No description in `variables.tf`. `string` (required)
- `app_vnet_rg`: No description in `variables.tf`. `string` (required)
- `iac_rg`: to define tfvars `string` (required)
- `app_admin_group`: Optional groups granted `Virtual Machine Administrator Login`, `Contributor` on each VM and NIC, and local `Administrators` membership when Windows can resolve the identity. Null and empty entries are ignored. `list(string)`
- `app_user_group`: Optional groups granted `Virtual Machine User Login`, `Reader` on each VM, and local `Remote Desktop Users` membership when Windows can resolve the identity. Null and empty entries are ignored. `list(string)`
- `iac_kv`: Shared IaC Key Vault name containing Windows VM bootstrap secrets. The module derives the vault resource ID from the current subscription, `iac_rg`, and this name. `string` (default: `"kvplatformccdev"`)
- `iac_st`: Shared IaC storage account name containing Windows VM bootstrap scripts. The module derives the storage account resource ID and `scripts` container blob URL from the current subscription, `iac_rg`, and this name. `string` (default: `"stplatformccdev"`)
- `enable_zone_spread`: Whether to spread multi-VM deployments across availability zones by default. `bool` (default: `true`)
- `availability_zones`: Availability zones used for round-robin placement when zone spread is enabled for multi-VM deployments. `list(string)` (default: `["1", "2", "3"]`)
- `azure-user`: Windows local administrator username override. Leave empty to use the configured Key Vault username secret. `string` (default: `""`)
- `azure-password`: Windows local administrator password override. Leave empty to use the configured Key Vault password secret. `string` (default: `""`)
- `admin_credentials_key_vault_id`: Optional Key Vault resource ID for the admin username/password secrets. When empty, the module falls back to the shared IaC Key Vault. `string` (default: `""`)
- `admin_username_secret_name`: Key Vault secret name used for the admin username fallback. `string` (default: `"azure-user"`)
- `admin_password_secret_name`: Key Vault secret name used for the admin password fallback. `string` (default: `"azure-password"`)
- `domain_join_user`: Domain join username override. Leave empty to use the configured Key Vault username secret. `string` (default: `""`)
- `domain_join_password`: Domain join password override. Leave empty to use the configured Key Vault password secret. `string` (default: `""`)
- `domain_join_username_secret_name`: Key Vault secret name used for the domain join username fallback. `string` (default: `"domain-join-user"`)
- `domain_join_password_secret_name`: Key Vault secret name used for the domain join password fallback. `string` (default: `"domain-join-password"`)
- `enable_diagnostics`: Enable sending diagnostics to Log Analytics `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics `string` (default: "")
- `windows_image_publisher`: Windows VM image publisher `string` (default: `"MicrosoftWindowsServer"`)
- `windows_image_offer`: Windows VM image offer `string` (default: `"WindowsServer"`)
- `windows_image_sku`: Windows VM image SKU, for example `2022-Datacenter` `string` (default: `"2022-Datacenter"`)
- `windows_image_version`: Windows VM image version `string` (default: `"latest"`)
- `tags`: Customized tags merged after inherited resource group tags. Values here override inherited values for matching keys. `map(string)` (default: {})

## Notable Outputs

- `diagnostics_enabled`: Whether VM diagnostics were configured
- `merged_tags`: Final merged tags applied to resources
- `principal_ids`: The principal_id of the VM's system-assigned identity
- `privateips`: No description in outputs file.
- `public_ip`: Output Public IP (if provisioned)
- `role_assignment_ids`: Role assignment IDs created by the module, including VM and NIC resource RBAC, VM login RBAC, Storage Blob Data Contributor, Key Vault access, and optional Data Factory Contributor.
- `vm_ids`: No description in outputs file.

## Access Model

- `app_admin_group` is the administrative access input. It is resolved to Entra group object IDs for Azure RBAC and is passed to `init2.ps1` for local `Administrators` membership.
- `app_user_group` is the user/RDP access input. It is resolved to Entra group object IDs for Azure RBAC and is passed to `init2.ps1` for local `Remote Desktop Users` membership.
- Object IDs are preferred for Azure RBAC. For Windows local group membership, the guest OS must be able to resolve the supplied value as a Windows account name or SID. GUID object IDs are skipped by the script for local group membership with a warning.
- The standalone validator is `scripts/validation.ps1`. Use `-AppAdminGroup` and `-AppUserGroup` to validate the local group outcomes on a provisioned VM.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
