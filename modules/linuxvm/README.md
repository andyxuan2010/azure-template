# Azure Linux Virtual Machine

Provisions one or more Linux virtual machines with NICs, optional public SSH access, data disks, managed identity, bootstrap and localization automation, Microsoft Entra SSH login, and scoped RBAC.

## Features

- Creates one or more Linux VMs from a configurable marketplace image.
- Supports dynamic or ordered static private IP addresses and optional zone spreading.
- Supports local SSH/password credentials directly or through an existing Key Vault.
- Enables a system-assigned managed identity by default.
- Runs built-in cloud-init plus optional caller-supplied post-initialization content.
- Supports optional storage-backed localization and Microsoft Entra SSH extensions.
- Creates optional managed data disks and Spot instances.
- Creates public IPs and restrictive SSH NSGs only when explicitly enabled.
- Assigns VM, NIC, resource-group, Bastion, storage, Key Vault, and Entra login roles when applicable.
- Inherits resource-group tags and lets caller tags take precedence.

## Resources Created

For each requested VM, the module creates a NIC and Linux VM. Depending on inputs, it can also create:

- public IPs, network security groups, and NIC/NSG associations;
- managed data disks and attachments;
- Microsoft Entra SSH and localization VM extensions;
- localization script blobs;
- role assignments at VM, NIC, resource-group, Bastion, storage, and Key Vault scopes.

The resource group, subnet, shared bootstrap storage account, shared Key Vault, and optional Bastion host are existing dependencies.

## Prerequisites and Dependencies

- Terraform 1.6 or newer.
- Existing target resource group and subnet.
- Existing shared IaC storage account and Key Vault; their names, IDs, and storage blob endpoint are required by the current interface.
- A valid SSH public key supplied directly or available from Key Vault.
- Permissions to read bootstrap secrets and create every enabled RBAC assignment.
- Optional Bastion host for private administration.

Review [`docs/authentication.md`](docs/authentication.md) and [`docs/operations.md`](docs/operations.md) before production adoption.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

The Terraform identity needs access to the VM resource group and the shared storage, Key Vault, and Bastion scopes referenced by the configuration.

## Basic Usage

```hcl
module "linux_vm" {
  source = "./modules/linuxvm"

  name                = "vm-orders"
  resource_group_name = "rg-orders-dev"
  subnet_id           = module.vnet.subnet_ids["snet-application"]

  iac_rg                       = "rg-platform-iac"
  iac_kv                       = "kv-platform-iac"
  iac_kv_id                    = module.bootstrap_key_vault.id
  iac_st                       = "stplatformiac"
  iac_st_id                    = module.bootstrap_storage.id
  iac_st_primary_blob_endpoint = module.bootstrap_storage.primary_blob_endpoint

  admin_username                  = "azureadmin"
  admin_ssh_key                   = var.admin_ssh_public_key
  disable_password_authentication = true
  bastion_resource_name           = ""
}
```

Runnable configurations are available in:

- [`examples/basic`](examples/basic/)
- [`examples/complete`](examples/complete/)
- [`examples/public-ssh`](examples/public-ssh/)

## Important Behavior and Secure Defaults

- Public networking is disabled and system-assigned identity is enabled by default.
- Password authentication is allowed by the module default for backward compatibility. Production callers should set `disable_password_authentication = true`.
- An effective SSH public key is mandatory even when password authentication is enabled.
- The shared storage and Key Vault dependencies are required by the current interface, even when some optional bootstrap features are disabled.
- Multi-VM deployments spread across configured availability zones by default.
- Public SSH requires both `public_network_enabled = true` and at least one trusted source prefix; never use unrestricted sources in production.
- Credentials, scripts, extension settings, and secret-derived values can enter Terraform state. Protect the backend.

## Networking and Access

The module consumes a direct subnet ID and creates NICs. It does not create the VNet, subnet, routes, private DNS, firewall rules, or Bastion host. Public networking creates one public IP and one SSH NSG per VM.

Prefer private administration through Azure Bastion, VPN/ExpressRoute, or a controlled management network. Static private IP lists must contain exactly one address per VM.

## Identity and RBAC

The VM identity receives access to the shared storage and Key Vault needed by bootstrap workflows. Optional admin/user principal IDs receive resource access and, when Entra SSH is enabled, the corresponding Virtual Machine Administrator Login or Virtual Machine User Login roles.

The module can also grant resource-group and Bastion roles. Review these assignments against least-privilege requirements because some are broader than VM-scoped access.

## Bootstrap and Operations

Built-in cloud-init executes [`scripts/init.sh`](scripts/init.sh). Optional inline `post_init_script` content runs in the same bootstrap path. The localization extension can download shared and VM-specific scripts from the existing storage account.

Operational details, troubleshooting, and lifecycle considerations are in [`docs/operations.md`](docs/operations.md). Script-specific notes remain in [`scripts/INIT.md`](scripts/INIT.md) and [`scripts/LOCALIZATION.md`](scripts/LOCALIZATION.md).

## Naming and Tagging

Set `name` for the base name; the module appends environment and instance details for individual VMs. `vm_name` is a deprecated compatibility alias. Caller tags override inherited resource-group tags.

Follow the repository [naming convention](../../docs/NAMING_CONVENTION.md) and [tagging standard](../../docs/TAGGING_STANDARD.md).

## Architecture

See [`docs/architecture.md`](docs/architecture.md) for dependency, bootstrap, identity, and network flows.

## Testing

`tests/unit.tftest.hcl` uses a mocked AzureRM provider with plan-only runs:

```powershell
terraform init -backend=false
terraform validate
terraform test
```

No Azure resources are deployed by these tests.

## Known Limitations

- The current interface requires several shared IaC storage and Key Vault inputs.
- The module creates individual VMs, not a Virtual Machine Scale Set or availability set.
- Only one optional data disk is modeled per VM.
- Domain-join and localization behavior depends on scripts and external services that plan-only tests cannot verify.
- Some legacy compatibility inputs remain but no longer drive subnet lookup.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_managed_disk.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_role_assignment.bastion_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.bastion_resource_group_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.nic_resource_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.resource_group_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2kv](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2kvsecrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2st](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm2st_localization_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_entra_admin_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_entra_user_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_resource_admin](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.vm_resource_user](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_blob.localization_vm_script](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_blob) | resource |
| [azurerm_virtual_machine_data_disk_attachment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment) | resource |
| [azurerm_virtual_machine_extension.entra_ssh_login](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |
| [azurerm_virtual_machine_extension.vm_extension_linux](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_credentials_key_vault_id"></a> [admin\_credentials\_key\_vault\_id](#input\_admin\_credentials\_key\_vault\_id) | Optional Azure Key Vault resource ID containing the admin username, password, and SSH public key secrets used by this module. | `string` | `""` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Optional admin password for the Linux VM local administrator account. When set, this overrides the Key Vault password secret. When unset, the module falls back to the configured Key Vault password secret and then to the module default. | `string` | `null` | no |
| <a name="input_admin_password_secret_name"></a> [admin\_password\_secret\_name](#input\_admin\_password\_secret\_name) | Key Vault secret name containing the Linux VM admin password. Used only when disable\_password\_authentication is false and admin\_password is not set. | `string` | `"azure-password"` | no |
| <a name="input_admin_ssh_key"></a> [admin\_ssh\_key](#input\_admin\_ssh\_key) | Optional SSH public key for the Linux VM local administrator account. When set, this overrides the Key Vault SSH key secret. When unset, the module falls back to the configured Key Vault SSH key secret and then to the module default. | `string` | `null` | no |
| <a name="input_admin_ssh_key_secret_name"></a> [admin\_ssh\_key\_secret\_name](#input\_admin\_ssh\_key\_secret\_name) | Key Vault secret name containing the Linux VM admin SSH public key. Used when admin\_ssh\_key is not set. The effective SSH key remains mandatory. | `string` | `"azureadmin-pubkey"` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Optional admin username for the Linux VM local administrator account. When set, this overrides the Key Vault username secret. When unset, the module falls back to the configured Key Vault username secret and then to the module default. | `string` | `null` | no |
| <a name="input_admin_username_secret_name"></a> [admin\_username\_secret\_name](#input\_admin\_username\_secret\_name) | Key Vault secret name containing the Linux VM admin username. Used only when disable\_password\_authentication is false and admin\_username is not set. | `string` | `"azure-user"` | no |
| <a name="input_app_admin_group"></a> [app\_admin\_group](#input\_app\_admin\_group) | Optional app admin group principal IDs granted Contributor on the VM resource and sudo/admin access inside the guest OS. Empty strings are ignored. | `list(string)` | `[]` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa' | `string` | `"dev"` | no |
| <a name="input_app_user_group"></a> [app\_user\_group](#input\_app\_user\_group) | Optional app user group principal IDs granted Reader on the VM resource and standard SSH access inside the guest OS. Empty strings are ignored. | `list(string)` | `[]` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Availability zones used for round-robin placement when enable\_zone\_spread is true and vm\_count is greater than 1. | `list(string)` | <pre>[<br>  "1",<br>  "2",<br>  "3"<br>]</pre> | no |
| <a name="input_bastion_resource_group_name"></a> [bastion\_resource\_group\_name](#input\_bastion\_resource\_group\_name) | Optional resource group containing the Bastion host referenced by bastion\_resource\_name. Set to null or empty string only when bastion\_resource\_name is also null or empty. | `string` | `"rg-ba-eus-prod-hub-network"` | no |
| <a name="input_bastion_resource_name"></a> [bastion\_resource\_name](#input\_bastion\_resource\_name) | Optional Azure Bastion host name used to grant Network Contributor access to app\_admin\_group and app\_user\_group when that RBAC is not already present. Set to null or empty string to skip Bastion RBAC. | `string` | `"bas-net-cc-prd"` | no |
| <a name="input_data_disk_size_gb"></a> [data\_disk\_size\_gb](#input\_data\_disk\_size\_gb) | Optional additional data disk size in GB. Set to 0 to skip the extra disk. | `number` | `0` | no |
| <a name="input_datadog_api_key"></a> [datadog\_api\_key](#input\_datadog\_api\_key) | Legacy Datadog API key input retained for backward compatibility. | `string` | `""` | no |
| <a name="input_disable_password_authentication"></a> [disable\_password\_authentication](#input\_disable\_password\_authentication) | Whether to disable password authentication on the Linux VM and enforce SSH key authentication. When true, admin\_username and admin\_password inputs and their Key Vault fallbacks are ignored. | `bool` | `false` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | AD domain used by the bootstrap script. | `string` | `"2join.us"` | no |
| <a name="input_domain_join_ou"></a> [domain\_join\_ou](#input\_domain\_join\_ou) | Legacy domain join OU value retained for compatibility. | `string` | `"azure"` | no |
| <a name="input_domain_join_user"></a> [domain\_join\_user](#input\_domain\_join\_user) | Optional domain join user in domain\username format. Leave empty to use domain\_join\_username\_secret\_name from Key Vault. | `string` | `""` | no |
| <a name="input_domain_join_username_secret_name"></a> [domain\_join\_username\_secret\_name](#input\_domain\_join\_username\_secret\_name) | Key Vault secret name containing the domain join username. Used only when domain\_join\_user is empty. | `string` | `"domain-join-user"` | no |
| <a name="input_enable_domain_join"></a> [enable\_domain\_join](#input\_enable\_domain\_join) | Whether to join the Linux VM to the domain during the bootstrap script. When false, the module skips the domain-join secret lookup and the bootstrap does not attempt AD join. | `bool` | `false` | no |
| <a name="input_enable_entra_ssh_login"></a> [enable\_entra\_ssh\_login](#input\_enable\_entra\_ssh\_login) | Whether to enable Microsoft Entra ID SSH login on the Linux VMs via the AADSSHLoginForLinux extension. | `bool` | `false` | no |
| <a name="input_enable_linux_vm_extension"></a> [enable\_linux\_vm\_extension](#input\_enable\_linux\_vm\_extension) | Whether to enable the optional storage-backed localization CustomScript VM extension for Linux VMs. Disabled by default. | `bool` | `false` | no |
| <a name="input_enable_spot_instance"></a> [enable\_spot\_instance](#input\_enable\_spot\_instance) | Whether to create the Linux VMs as Azure Spot instances. When false, regular pay-as-you-go VMs are created. | `bool` | `false` | no |
| <a name="input_enable_system_assigned_identity"></a> [enable\_system\_assigned\_identity](#input\_enable\_system\_assigned\_identity) | Whether to enable a system-assigned managed identity on the Linux VMs. Defaults to true. | `bool` | `true` | no |
| <a name="input_enable_zone_spread"></a> [enable\_zone\_spread](#input\_enable\_zone\_spread) | Whether to spread multi-VM deployments across availability zones by default. When enabled and vm\_count is greater than 1, the module assigns zones in round-robin order from availability\_zones. | `bool` | `true` | no |
| <a name="input_iac_kv"></a> [iac\_kv](#input\_iac\_kv) | Shared Key Vault name containing Linux VM secrets. | `string` | n/a | yes |
| <a name="input_iac_kv_id"></a> [iac\_kv\_id](#input\_iac\_kv\_id) | Shared Key Vault resource ID containing Linux VM secrets. | `string` | n/a | yes |
| <a name="input_iac_rg"></a> [iac\_rg](#input\_iac\_rg) | Resource group containing the shared IaC storage account and Key Vault. | `string` | n/a | yes |
| <a name="input_iac_st"></a> [iac\_st](#input\_iac\_st) | Shared storage account name containing bootstrap scripts. | `string` | n/a | yes |
| <a name="input_iac_st_id"></a> [iac\_st\_id](#input\_iac\_st\_id) | Shared storage account resource ID containing bootstrap scripts. | `string` | n/a | yes |
| <a name="input_iac_st_primary_blob_endpoint"></a> [iac\_st\_primary\_blob\_endpoint](#input\_iac\_st\_primary\_blob\_endpoint) | Primary blob endpoint for the shared storage account containing bootstrap scripts. | `string` | n/a | yes |
| <a name="input_image_offer"></a> [image\_offer](#input\_image\_offer) | Offer of the Linux VM image. | `string` | `"ubuntu-24_04-lts"` | no |
| <a name="input_image_publisher"></a> [image\_publisher](#input\_image\_publisher) | Publisher of the Linux VM image. | `string` | `"Canonical"` | no |
| <a name="input_image_sku"></a> [image\_sku](#input\_image\_sku) | SKU of the Linux VM image. | `string` | `"server"` | no |
| <a name="input_image_version"></a> [image\_version](#input\_image\_version) | Version of the Linux VM image. | `string` | `"latest"` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Linux VM resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_localization_container_name"></a> [localization\_container\_name](#input\_localization\_container\_name) | Blob container name in the shared IaC storage account that holds Linux VM localization scripts for the optional VM extension. | `string` | `"localization"` | no |
| <a name="input_localization_os_script_name"></a> [localization\_os\_script\_name](#input\_localization\_os\_script\_name) | The OS-level localization script blob name to download first when the optional Linux VM extension is enabled, for example ubuntu.sh or rhel.sh. | `string` | `"ubuntu.sh"` | no |
| <a name="input_localization_vm_script_content"></a> [localization\_vm\_script\_content](#input\_localization\_vm\_script\_content) | Optional map of VM-specific localization blob content keyed by blob name, for example { "myvm001.sh" = file("scripts/myvm001.sh") }. When provided, the module uploads these hostname-specific scripts to the localization container in the shared IaC storage account. | `map(string)` | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region in which all resources in this example should be created. | `string` | `"canadacentral"` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional base Linux VM name override. Leave empty to generate a compact base name; environment/instance suffixes are appended by the module. | `string` | `""` | no |
| <a name="input_post_init_script"></a> [post\_init\_script](#input\_post\_init\_script) | Optional inline bash content appended after the module's built-in init.sh bootstrap. This runs in the same custom\_data/cloud-init execution path after the base init.sh logic finishes, before the optional Linux VM extension hook. | `string` | `""` | no |
| <a name="input_private_ip_addresses"></a> [private\_ip\_addresses](#input\_private\_ip\_addresses) | Optional static private IP addresses for the Linux VM NICs. Leave empty for dynamic private IP allocation. When provided, specify exactly one IP address per VM in vm\_count order. | `list(string)` | `[]` | no |
| <a name="input_public_network_enabled"></a> [public\_network\_enabled](#input\_public\_network\_enabled) | Whether to create public IPs and NSGs for SSH access. | `bool` | `false` | no |
| <a name="input_public_ssh_source_address_prefixes"></a> [public\_ssh\_source\_address\_prefixes](#input\_public\_ssh\_source\_address\_prefixes) | Trusted IPv4/IPv6 addresses or CIDR prefixes allowed to SSH when public\_network\_enabled is true. | `list(string)` | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Target resource group name for the Linux VM resources. | `string` | n/a | yes |
| <a name="input_spot_eviction_policy"></a> [spot\_eviction\_policy](#input\_spot\_eviction\_policy) | Eviction policy for Spot Linux VMs. Used only when enable\_spot\_instance is true. Valid values are Deallocate or Delete. | `string` | `"Deallocate"` | no |
| <a name="input_spot_max_bid_price"></a> [spot\_max\_bid\_price](#input\_spot\_max\_bid\_price) | Maximum hourly price for Spot Linux VMs. Used only when enable\_spot\_instance is true. Set to -1 to pay up to the current on-demand price. | `number` | `-1` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet resource ID used directly for the VM NICs. | `string` | n/a | yes |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Legacy subnet name input retained for compatibility. Prefer subnet\_id. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Custom tags applied to Linux VM resources. These override inherited resource group tags. | `map(string)` | `{}` | no |
| <a name="input_vm_count"></a> [vm\_count](#input\_vm\_count) | Number of Linux VMs to create. | `number` | `1` | no |
| <a name="input_vm_name"></a> [vm\_name](#input\_vm\_name) | Deprecated alias for name. Use name for the base Linux VM name override. | `string` | `""` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size for each Linux VM. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | Legacy virtual network resource ID input retained for compatibility. The module no longer resolves subnet IDs from VNet inputs. | `string` | `""` | no |
| <a name="input_vnet_name"></a> [vnet\_name](#input\_vnet\_name) | Legacy virtual network name input retained for compatibility. Prefer vnet\_id. | `string` | `""` | no |
| <a name="input_vnet_resource_group_name"></a> [vnet\_resource\_group\_name](#input\_vnet\_resource\_group\_name) | Legacy virtual network resource group input retained for compatibility. Prefer vnet\_id. | `string` | `""` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used in naming and tagging. | `string` | `"ccoetest"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_computer_name"></a> [computer\_name](#output\_computer\_name) | List of Linux VM computer names. |
| <a name="output_entra_ssh_login_extension_ids"></a> [entra\_ssh\_login\_extension\_ids](#output\_entra\_ssh\_login\_extension\_ids) | List of Entra SSH login VM extension IDs, if enabled. |
| <a name="output_id"></a> [id](#output\_id) | List of Linux virtual machine IDs. |
| <a name="output_linux_vm_extension_ids"></a> [linux\_vm\_extension\_ids](#output\_linux\_vm\_extension\_ids) | List of localization CustomScript VM extension IDs, if enabled. |
| <a name="output_managed_disk_ids"></a> [managed\_disk\_ids](#output\_managed\_disk\_ids) | List of managed data disk IDs. |
| <a name="output_managed_identity_principal_ids"></a> [managed\_identity\_principal\_ids](#output\_managed\_identity\_principal\_ids) | List of system-assigned managed identity principal IDs. Returns an empty list when system-assigned identity is disabled. |
| <a name="output_name"></a> [name](#output\_name) | List of Linux virtual machine names. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | List of network interface IDs. |
| <a name="output_network_interface_names"></a> [network\_interface\_names](#output\_network\_interface\_names) | List of network interface names. |
| <a name="output_network_security_group_ids"></a> [network\_security\_group\_ids](#output\_network\_security\_group\_ids) | List of network security group IDs created for public networking, if enabled. |
| <a name="output_network_security_group_names"></a> [network\_security\_group\_names](#output\_network\_security\_group\_names) | List of network security group names created for public networking, if enabled. |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | List of private IP addresses assigned to the VM NICs. |
| <a name="output_private_ip_by_vm_name"></a> [private\_ip\_by\_vm\_name](#output\_private\_ip\_by\_vm\_name) | Map of Linux VM name to private IP address. |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | List of public IP addresses, if public networking is enabled. |
| <a name="output_public_ip_ids"></a> [public\_ip\_ids](#output\_public\_ip\_ids) | List of public IP resource IDs, if public networking is enabled. |
| <a name="output_role_assignment_ids"></a> [role\_assignment\_ids](#output\_role\_assignment\_ids) | Role assignment IDs created for VM resource RBAC, NIC resource RBAC, optional Entra VM login RBAC, Storage Blob Data Contributor, optional localization Storage Blob Data Reader, Key Vault Reader, and Key Vault Secrets User. |
| <a name="output_tags"></a> [tags](#output\_tags) | The effective tags assigned to the Linux VM resources. |
<!-- END_TF_DOCS -->
