# Windows VM Module

Provision Windows virtual machines with bootstrap, RBAC, SHIR integration, networking, and optional diagnostics.

## Overview

- Providers: `azuread` `3.8.0`, `azurerm` `4.65.0`
- Inputs: 29
- Outputs: 7
- Nested modules: 0
- Terraform tests: `tests/live.tftest.hcl`

## Features

- Creates managed resources including `azurerm_managed_disk`, `azurerm_network_interface`, `azurerm_network_interface_security_group_association`, `azurerm_network_security_group`, `azurerm_public_ip`.
- Grants `app_admin_group` `Contributor` on each VM resource and each module-created NIC, and grants `app_user_group` `Reader` on each VM resource.
- Spreads multi-VM deployments across availability zones by default when `app_vm_number > 1`, using round-robin placement from `availability_zones`.
- Supports optional diagnostic settings to Log Analytics.
- Includes SHIR-related wiring for Data Factory scenarios.
- Includes Terraform test coverage files: `tests/live.tftest.hcl`.

The module resolves administrator credentials in this order:

- Use `azure-user` and `azure-password` input values when they are non-empty.
- Otherwise fall back to the `azure-user` and `azure-password` secrets in the module Key Vault.

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
  iac_kv = "<iac_kv>"
  iac_rg = "<iac_rg>"
  iac_st = "<iac_st>"
  windows_image_publisher = "MicrosoftWindowsServer"
  windows_image_offer     = "WindowsServer"
  windows_image_sku       = "2022-Datacenter"
  windows_image_version   = "latest"
  azure-user              = "azureadmin"
  azure-password          = "ChangeMe123!"

  tags = {
    ManagedBy = "Terraform"
  }
}
```

## Common Image Choices

Pick the image family based on the VM's purpose, then keep `windows_image_publisher`, `windows_image_offer`, `windows_image_sku`, and `windows_image_version` aligned to that family.

- General-purpose Windows Server VM:
  `windows_image_publisher = "MicrosoftWindowsServer"`, `windows_image_offer = "WindowsServer"`, `windows_image_sku = "2022-Datacenter"`
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
- `iac_kv`: No description in `variables.tf`. `string` (required)
- `iac_rg`: to define tfvars `string` (required)
- `iac_st`: No description in `variables.tf`. `string` (required)
- `app_admin_group`: AD groups granted Contributor on each VM resource, Contributor on each module-created NIC, and elevated guest login access where applicable. `list(string)` (default: ["BA-G-CCOE-Admin-F", "BA-G-Azure-Owner-F"])
- `app_user_group`: AD groups granted Reader on each VM resource and standard guest login access where applicable. `list(string)` (default: [])
- `enable_zone_spread`: Whether to spread multi-VM deployments across availability zones by default. `bool` (default: `true`)
- `availability_zones`: Availability zones used for round-robin placement when zone spread is enabled for multi-VM deployments. `list(string)` (default: `["1", "2", "3"]`)
- `azure-user`: Windows local administrator username override. Leave empty to use the `azure-user` Key Vault secret. `string` (default: `""`)
- `azure-password`: Windows local administrator password override. Leave empty to use the `azure-password` Key Vault secret. `string` (default: `""`)
- `enable_diagnostics`: Enable sending diagnostics to Log Analytics `bool` (default: false)
- `log_analytics_workspace_id`: Log Analytics workspace resource ID for diagnostics `string` (default: "")
- `windows_image_publisher`: Windows VM image publisher `string` (default: `"MicrosoftWindowsServer"`)
- `windows_image_offer`: Windows VM image offer `string` (default: `"WindowsServer"`)
- `windows_image_sku`: Windows VM image SKU, for example `2022-Datacenter` `string` (default: `"2022-Datacenter"`)
- `windows_image_version`: Windows VM image version `string` (default: `"latest"`)
- `tags`: customized tags `map(string)` (default: {})

## Notable Outputs

- `diagnostics_enabled`: Whether VM diagnostics were configured
- `merged_tags`: Final merged tags applied to resources
- `principal_ids`: The principal_id of the VM's system-assigned identity
- `privateips`: No description in outputs file.
- `public_ip`: Output Public IP (if provisioned)
- `role_assignment_ids`: Role assignment IDs created by the module, including VM and NIC resource RBAC, VM login RBAC, Storage Blob Data Contributor, Key Vault access, and optional Data Factory Contributor.
- `vm_ids`: No description in outputs file.

## Testing

Run module tests from the module directory:

```powershell
terraform test
```

- `terraform test -filter='tests\live.tftest.hcl'`
