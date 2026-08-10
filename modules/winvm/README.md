# Azure Windows Virtual Machines

Provisions one or more Windows Server virtual machines with private networking, system-assigned identity, Azure RBAC, optional domain or Microsoft Entra login, optional bootstrap execution, data disks, restricted public RDP, Self-hosted Integration Runtime integration, and per-VM diagnostics.

## Features

- Creates multiple Windows VMs and NICs in an existing subnet with dynamic or static private addresses.
- Supports round-robin Availability Zone placement or an existing Availability Set.
- Resolves administrator and domain-join credentials from direct inputs or Key Vault.
- Supports mutually exclusive Microsoft Entra login and Active Directory domain join.
- Supports an optional Windows primary DNS suffix override after domain join; leave `primary_dns_suffix` empty to use the AD domain suffix.
- Runs the bundled Windows baseline through Custom Script Extension or VM Run Command.
- Grants VM identities access to shared script storage and Key Vault, with optional Azure Data Factory integration.
- Supports optional managed data disks, public IPs with source-restricted RDP, group RBAC, and diagnostics.

## Resources Created

The module always creates each requested VM, NIC, system-assigned identity, Network Watcher extension, and shared storage/Key Vault role assignments. Managed disks, login/domain/bootstrap extensions, Run Command, public IP/NSG resources, group role assignments, Data Factory access, and diagnostic settings are conditional.

The application resource group, VNet, subnet, Key Vault secrets, and Microsoft Entra groups are looked up but not managed. Shared Key Vault and storage resource IDs are derived from the current subscription and naming inputs.

See [architecture](docs/architecture.md), [bootstrap operations](docs/operations.md), and [pipeline notes](docs/pipeline.md).

## Prerequisites and Dependencies

- Existing application and shared-IaC resource groups, VNet, subnet, Key Vault, and storage account
- A `scripts` Blob container containing the bootstrap assets documented in [operations](docs/operations.md)
- Private DNS, routing, and outbound access for Azure extensions, Windows Update, packages, domain services, and optional SHIR
- Administrator credentials supplied directly or through named Key Vault secrets
- Microsoft Entra object IDs or unique display names for access groups
- A Log Analytics workspace for diagnostics and an Azure Data Factory resource for SHIR when selected
- Sufficient permissions to read dependencies, read secrets, create compute/network resources, and create all requested role assignments

## Provider Configuration

The caller must configure AzureRM 4.x and AzureAD 3.x. The execution identity requires broad dependency-read and role-assignment rights in addition to VM, NIC, disk, extension, Run Command, public IP, NSG, and diagnostic-setting permissions.

## Basic Usage

```hcl
module "winvm" {
  source = "./modules/winvm"

  iac_rg      = "rg-platform-prod"
  app_rg      = "rg-app-prod"
  app_vnet_rg = "rg-network-prod"
  app_vnet    = "vnet-spoke-prod"
  app_snet    = "snet-app"

  azure-user     = var.admin_username
  azure-password = var.admin_password

  app_admin_group = []
  app_user_group  = []
}
```

The complete executable configuration is in [`examples/basic`](examples/basic/).

## Important Behavior and Secure Defaults

- Public networking is disabled by default. Enabling it requires at least one explicit trusted RDP source; there is no open-internet default.
- Microsoft Entra login defaults to enabled. It cannot be enabled together with Active Directory domain join.
- Custom Script Extension and VM Run Command are mutually exclusive. VM Run Command is preferred for current consumers.
- The VM identity always receives `Storage Blob Data Contributor`, `Key Vault Reader`, and `Key Vault Secrets Officer` on derived shared resources. Review this access model before deployment.
- VM `custom_data` changes are ignored to prevent bootstrap script changes from replacing an existing VM. Use the Run Command replacement trigger to rerun bootstrap intentionally.
- Multiple VMs use environment-specific numeric suffixes and optionally spread across zones. Static IP count must equal VM count.
- Image, size, disk, extension, public IP, and Log Analytics choices can incur significant cost.

## Networking and Private Connectivity

The module consumes an existing subnet. It creates no VNet, subnet, routes, private DNS, Bastion, VPN, or private endpoints. Public mode creates one Standard public IP and one NSG per VM with TCP/3389 limited to `rdp_source_address_prefixes`; private access through Bastion, VPN, or ExpressRoute is preferred.

## Identity and RBAC

Every VM receives a system-assigned identity. Application administrators receive VM Administrator Login plus Contributor on each VM/NIC; application users receive VM User Login plus Reader on each VM. Object IDs are preferred over display names.

When SHIR is enabled, VM identities receive Data Factory Contributor on `adf_id`. Domain-join credentials are passed to the protected settings of `JsonADDomainExtension`.

## Naming and Tagging

Set `name` or allow a compact generated base from workload, location, and environment. `app_vm` is a deprecated alias. A three-digit environment/instance suffix is appended and Windows names remain within 15 characters. Caller tags override inherited application resource-group tags. See the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Examples

- [`basic`](examples/basic/): one private VM with direct administrator credentials
- [`complete`](examples/complete/): two zonal VMs with static addresses, Run Command bootstrap, diagnostics, and Entra groups
- [`self-hosted-integration-runtime`](examples/self-hosted-integration-runtime/): private SHIR host with Azure Data Factory RBAC

## Testing

`tests/unit.tftest.hcl` uses mocked AzureRM and AzureAD providers. Its three plan-only tests require no Azure authentication, create no resources, and incur no cost.

```powershell
terraform -chdir=modules/winvm init -backend=false
terraform -chdir=modules/winvm test
```

Parse the maintained PowerShell scripts after bootstrap changes:

```powershell
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile(
  'modules\winvm\scripts\init2.ps1',
  [ref]$tokens,
  [ref]$errors
) | Out-Null
$errors
```

## Known Limitations

- Shared Key Vault and storage resource IDs are derived in the current provider subscription; cross-subscription shared-IaC resources are not supported by those inputs.
- The built-in Key Vault roles include Secrets Officer, which may exceed runtime-only least privilege.
- Bootstrap success depends on guest DNS, outbound connectivity, package repositories, storage assets, identity propagation, and domain/ADF availability that mocked plans cannot verify.
- The module does not create backup, Update Manager schedules, Bastion, recovery testing, or a domain.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | >= 3.0, < 4.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | >= 3.0, < 4.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.nic_resource_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2adf](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2kvsecrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2st](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_admin_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_resource_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_resource_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_user_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.CustomScriptInit](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.NetworkWatcherAgentWindows](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.aad_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.domain_join_ext](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_run_command.Init](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_run_command) | resource |
| [azurerm_windows_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine) | resource |
| [terraform_data.run_command_replace_trigger](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_AADLoginForWindows"></a> [AADLoginForWindows](#input\_AADLoginForWindows) | Whether to install the Microsoft Entra login extension for Windows. Mutually exclusive with Active Directory domain join. | `bool` | `true` | no |
| <a name="input_adf_id"></a> [adf\_id](#input\_adf\_id) | Resource ID of the target ADF for RBAC scope | `string` | `null` | no |
| <a name="input_admin_credentials_key_vault_id"></a> [admin\_credentials\_key\_vault\_id](#input\_admin\_credentials\_key\_vault\_id) | Optional Azure Key Vault resource ID containing the Windows VM admin username and password secrets. When empty, the module falls back to the shared IaC Key Vault. | `string` | `""` | no |
| <a name="input_admin_password_secret_name"></a> [admin\_password\_secret\_name](#input\_admin\_password\_secret\_name) | Key Vault secret name containing the Windows VM admin password. Used only when azure-password is empty. | `string` | `"azure-password"` | no |
| <a name="input_admin_username_secret_name"></a> [admin\_username\_secret\_name](#input\_admin\_username\_secret\_name) | Key Vault secret name containing the Windows VM admin username. Used only when azure-user is empty. | `string` | `"azure-user"` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional groups granted admin RBAC on each VM and NIC, and added to the VM Administrators group where Windows-resolvable. Null and empty entries are ignored. | `list(string)` | <pre>[<br>  "7a958d36-a182-451e-8012-4e8fe9386dc7",<br>  "BA-G-Azure-Owner-F"<br>]</pre> | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used for VM instance suffixes and conditional behavior. | `string` | `"dev"` | no |
| <a name="input_app_rg"></a> [app\_rg](#input\_app\_rg) | Existing application resource group where Windows VM resources are created. | `string` | n/a | yes |
| <a name="input_app_snet"></a> [app\_snet](#input\_app\_snet) | Existing subnet name used by the Windows VM network interfaces. | `string` | n/a | yes |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional groups granted user RBAC on each VM, and added to the VM Remote Desktop Users group where Windows-resolvable. Null and empty entries are ignored. | `list(string)` | `[]` | no |
| <a name="input_app_vm"></a> [app\_vm](#input\_app\_vm) | Deprecated alias for name. Use name for the base Windows VM name override. | `string` | `""` | no |
| <a name="input_app_vm_number"></a> [app\_vm\_number](#input\_app\_vm\_number) | Number of Windows VMs and NICs to create. | `number` | `1` | no |
| <a name="input_app_vm_size"></a> [app\_vm\_size](#input\_app\_vm\_size) | Azure VM size used for every Windows VM instance. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_app_vnet"></a> [app\_vnet](#input\_app\_vnet) | Existing application VNet name. | `string` | n/a | yes |
| <a name="input_app_vnet_rg"></a> [app\_vnet\_rg](#input\_app\_vnet\_rg) | Existing resource group containing the application VNet. | `string` | n/a | yes |
| <a name="input_availability_set_id"></a> [availability\_set\_id](#input\_availability\_set\_id) | Optional Availability Set ID for VM placement. Do not combine with availability zone spread. | `string` | `null` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones used for round-robin placement when enable\_zone\_spread is true and app\_vm\_number is greater than 1. | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |
| <a name="input_azure-password"></a> [azure-password](#input\_azure-password) | Admin password for the Windows VM local administrator account. Used directly when non-empty; otherwise the module falls back to the configured Key Vault password secret. | `string` | `""` | no |
| <a name="input_azure-user"></a> [azure-user](#input\_azure-user) | Admin username for the Windows VM local administrator account. Used directly when non-empty; otherwise the module falls back to the configured Key Vault username secret. | `string` | `""` | no |
| <a name="input_disksize"></a> [disksize](#input\_disksize) | Size in GiB of one optional managed data disk per VM. Set to 0 to disable data disks. | `number` | `0` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | Active Directory domain name used by JsonADDomainExtension when domain join is enabled. | `string` | `"2join.us"` | no |
| <a name="input_domain_join_password"></a> [domain\_join\_password](#input\_domain\_join\_password) | Domain join password override. Leave empty to use the configured Key Vault password secret. | `string` | `""` | no |
| <a name="input_domain_join_password_secret_name"></a> [domain\_join\_password\_secret\_name](#input\_domain\_join\_password\_secret\_name) | Key Vault secret name containing the domain join password. Used only when domain\_join\_password is empty. | `string` | `"domain-join-password"` | no |
| <a name="input_domain_join_user"></a> [domain\_join\_user](#input\_domain\_join\_user) | Domain join username override in domain\username format. Leave empty to use the configured Key Vault username secret. | `string` | `""` | no |
| <a name="input_domain_join_username_secret_name"></a> [domain\_join\_username\_secret\_name](#input\_domain\_join\_username\_secret\_name) | Key Vault secret name containing the domain join username. Used only when domain\_join\_user is empty. | `string` | `"domain-join-user"` | no |
| <a name="input_enable_custom_script_extension"></a> [enable\_custom\_script\_extension](#input\_enable\_custom\_script\_extension) | Whether to attach the CustomScriptExtension that runs the Windows bootstrap script. | `bool` | `false` | no |
| <a name="input_enable_defender_performance_mode"></a> [enable\_defender\_performance\_mode](#input\_enable\_defender\_performance\_mode) | Whether the Windows bootstrap script may temporarily adjust Microsoft Defender settings during heavy software installation steps. | `bool` | `false` | no |
| <a name="input_enable_diagnostics"></a> [enable\_diagnostics](#input\_enable\_diagnostics) | Whether to create one diagnostic setting per VM targeting Log Analytics. | `bool` | `false` | no |
| <a name="input_enable_domain_join"></a> [enable\_domain\_join](#input\_enable\_domain\_join) | Whether to join the Windows VM to the domain through JsonADDomainExtension. | `bool` | `false` | no |
| <a name="input_enable_shir"></a> [enable\_shir](#input\_enable\_shir) | Enable Self Hosted Integration Runtime bootstrap and related ADF RBAC wiring. | `bool` | `false` | no |
| <a name="input_enable_virtual_machine_run_command"></a> [enable\_virtual\_machine\_run\_command](#input\_enable\_virtual\_machine\_run\_command) | Whether to run the Windows bootstrap script through azurerm\_virtual\_machine\_run\_command instead of the CustomScriptExtension. | `bool` | `false` | no |
| <a name="input_enable_zone_spread"></a> [enable\_zone\_spread](#input\_enable\_zone\_spread) | Whether to spread multi-VM deployments across availability zones by default. When enabled and app\_vm\_number is greater than 1, the module assigns zones in round-robin order from availability\_zones. | `bool` | `true` | no |
| <a name="input_iac_kv"></a> [iac\_kv](#input\_iac\_kv) | Shared IaC Key Vault name containing Windows VM bootstrap secrets. | `string` | `"kvplatformccdev"` | no |
| <a name="input_iac_rg"></a> [iac\_rg](#input\_iac\_rg) | Existing shared IaC resource group containing the bootstrap Key Vault and Storage account. | `string` | n/a | yes |
| <a name="input_iac_st"></a> [iac\_st](#input\_iac\_st) | Shared IaC storage account name containing Windows VM bootstrap scripts. | `string` | `"stplatformccdev"` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Windows VM resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_localization_container_name"></a> [localization\_container\_name](#input\_localization\_container\_name) | Blob container name in the shared IaC storage account that holds consumer-owned Windows localization scripts such as windows-localization.ps1 and <COMPUTERNAME>.ps1. | `string` | `"localization"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where the Windows VM resources are created. | `string` | `"canadacentral"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Log Analytics workspace resource ID required when diagnostics are enabled. | `string` | `""` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional base Windows VM name override. Leave empty to generate a compact base name; environment/instance suffixes are appended by the module. | `string` | `""` | no |
| <a name="input_patch_mode"></a> [patch\_mode](#input\_patch\_mode) | Specifies the mode of VM Guest Patching to IaaS virtual machine or virtual machine scale set. Possible values are Manual, AutomaticByOS and AutomaticByPlatform. | `string` | `"AutomaticByPlatform"` | no |
| <a name="input_primary_dns_suffix"></a> [primary\_dns\_suffix](#input\_primary\_dns\_suffix) | Optional Windows primary DNS suffix override applied after Active Directory domain join. Leave empty to retain the domain-join default. A reboot is scheduled when the suffix changes. | `string` | `""` | no |
| <a name="input_private_ip_addresses"></a> [private\_ip\_addresses](#input\_private\_ip\_addresses) | Optional static private IP addresses for the Windows VM NICs. Leave empty for dynamic private IP allocation. When provided, specify exactly one IP address per VM in app\_vm\_number order. | `list(string)` | `[]` | no |
| <a name="input_public_network_enabled"></a> [public\_network\_enabled](#input\_public\_network\_enabled) | Whether to create one public IP and source-restricted RDP NSG per VM. | `bool` | `false` | no |
| <a name="input_rdp_source_address_prefixes"></a> [rdp\_source\_address\_prefixes](#input\_rdp\_source\_address\_prefixes) | Trusted IPv4 addresses or CIDR ranges allowed to reach RDP when public\_network\_enabled is true. Deliberately has no open-internet default. | `list(string)` | `[]` | no |
| <a name="input_run_command_replace_trigger"></a> [run\_command\_replace\_trigger](#input\_run\_command\_replace\_trigger) | Optional external trigger value that forces the Windows Run Command bootstrap resource to be replaced when changed. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags merged over inherited application resource-group tags and applied to Windows VM resources. | `map(string)` | `{}` | no |
| <a name="input_vm_admin_group"></a> [vm\_admin\_group](#input\_vm\_admin\_group) | Optional Microsoft Entra group display name or object ID granted Virtual Machine Administrator Login on each VM. | `string` | `null` | no |
| <a name="input_vm_remote_group"></a> [vm\_remote\_group](#input\_vm\_remote\_group) | Optional Microsoft Entra group display name or object ID granted Virtual Machine User Login on each VM. | `string` | `null` | no |
| <a name="input_windows_group_domain_prefix"></a> [windows\_group\_domain\_prefix](#input\_windows\_group\_domain\_prefix) | Optional Windows domain or NetBIOS prefix applied to bare app\_admin\_group and app\_user\_group names before local group membership, Already-qualified names and SIDs are not changed. | `string` | `""` | no |
| <a name="input_windows_image_offer"></a> [windows\_image\_offer](#input\_windows\_image\_offer) | Offer of the Windows VM image. | `string` | `"WindowsServer"` | no |
| <a name="input_windows_image_publisher"></a> [windows\_image\_publisher](#input\_windows\_image\_publisher) | Publisher of the Windows VM image. | `string` | `"MicrosoftWindowsServer"` | no |
| <a name="input_windows_image_sku"></a> [windows\_image\_sku](#input\_windows\_image\_sku) | SKU of the Windows VM image, for example 2022-Datacenter. | `string` | `"2025-Datacenter"` | no |
| <a name="input_windows_image_version"></a> [windows\_image\_version](#input\_windows\_image\_version) | Version of the Windows VM image. | `string` | `"latest"` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in tagging. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids) | Diagnostic setting IDs keyed by VM index. |
| <a name="output_diagnostics_enabled"></a> [diagnostics\_enabled](#output\_diagnostics\_enabled) | Whether VM diagnostic settings were configured. |
| <a name="output_merged_tags"></a> [merged\_tags](#output\_merged\_tags) | Final merged tags applied to Windows VM resources. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | Network interface IDs for all Windows VMs in index order. |
| <a name="output_network_interface_ip_configuration_names"></a> [network\_interface\_ip\_configuration\_names](#output\_network\_interface\_ip\_configuration\_names) | Primary NIC IP configuration names for all Windows VMs in index order. |
| <a name="output_principal_ids"></a> [principal\_ids](#output\_principal\_ids) | System-assigned managed identity principal IDs for the Windows VMs. |
| <a name="output_privateips"></a> [privateips](#output\_privateips) | Private IP addresses for all Windows VMs in index order. |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | First public IP address for backward compatibility, or null when public networking is disabled. |
| <a name="output_public_ips"></a> [public\_ips](#output\_public\_ips) | Public IP addresses for all VMs, or an empty list when public networking is disabled. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Role assignment IDs created for VM resource RBAC, NIC resource RBAC, VM login RBAC, Storage Blob Data Contributor, Key Vault Reader, Key Vault secrets access, and optional Data Factory Contributor. |
| <a name="output_vm_ids"></a> [vm\_ids](#output\_vm\_ids) | Windows VM resource IDs in index order. |
<!-- END_TF_DOCS -->
