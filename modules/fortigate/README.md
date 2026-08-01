# FortiGate-VM on Azure

Provisions private single-instance or active-passive FortiGate-VM infrastructure with configurable interfaces, optional module-owned networking, NSGs, and internal or external Standard Load Balancers.

## Features

- Supports `single` and `active-passive` architectures.
- Uses existing subnet IDs, creates subnets in an existing VNet, or creates a dedicated VNet and subnets.
- Supports BYOL and PAYG Marketplace image and plan inputs.
- Creates multiple NICs with static or dynamic private addresses and optional accelerated networking.
- Creates an optional shared NSG and caller-defined security rules.
- Supports private internal and external load-balancer frontends by default.
- Creates an external public load-balancer frontend only through explicit opt-in.
- Accepts SSH key or password credentials directly or from an existing Key Vault.
- Supports FortiOS bootstrap configuration through sensitive custom data.

## Resources Created

Depending on configuration, the module creates:

- One or two Linux virtual machines.
- Network interfaces for each enabled FortiGate interface.
- An optional VNet and interface subnets.
- An optional NSG and subnet associations.
- Optional internal and external Standard Load Balancers, probes, rules, and backend associations.
- An optional Standard public IP for the external load balancer.

The module may read an existing resource group, VNet, and Key Vault secrets. FortiManager, FortiAnalyzer, licenses, DNS, route tables, monitoring, and FortiOS runtime configuration remain caller-owned.

## Prerequisites and Dependencies

- An existing resource group.
- Existing interface subnets, or approved address space when the module owns the VNet/subnets.
- Accepted Fortinet Marketplace terms and a BYOL entitlement or PAYG selection matching the image and plan.
- A supported VM size and sufficient regional quota.
- A protected SSH public key or password, preferably obtained from Key Vault.
- Route tables, IP forwarding, probe response, NSG rules, and upstream/downstream traffic design.
- Terraform `>= 1.6.0` and AzureRM `>= 4.0, < 5.0`.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

The Terraform identity needs permission to manage compute and network resources and read configured Key Vault secrets.

## Basic Usage

See the executable [basic example](examples/basic/), [complete example](examples/complete/), and [dedicated network example](examples/dedicated-network/).

```hcl
module "fortigate" {
  source = "../../modules/fortigate"

  architecture         = "single"
  resource_group_name  = azurerm_resource_group.network.name
  location             = azurerm_resource_group.network.location
  name_prefix          = "fgt-hub-prod"
  admin_ssh_public_key = var.admin_ssh_public_key

  interfaces = {
    external = {
      role      = "external"
      subnet_id = module.vnet.subnet_ids["snet-fortigate-external"]
      primary   = true
      private_ip_addresses = {
        a = "10.20.0.4"
      }
    }
    internal = {
      role      = "internal"
      subnet_id = module.vnet.subnet_ids["snet-fortigate-internal"]
      private_ip_addresses = {
        a = "10.20.1.4"
      }
    }
  }
}
```

## Important Behavior and Secure Defaults

- No public IP is created unless `external_load_balancer.create_public_ip = true`.
- No inbound NSG rule is created by default.
- Management is private by default and public VM administration is not implemented.
- At least one administrator password or SSH public key must resolve from direct input or Key Vault.
- IP forwarding is enabled on appliance interfaces by default.
- The default Marketplace image version is `latest`; production deployments should deliberately control upgrade behavior and validate the selected image.
- VM, disks, load balancers, public IPs, and FortiGate licensing are billable.

## Networking and Traffic Flow

Existing-subnet mode keeps network ownership in the calling composition. Module-owned subnet and VNet modes are convenient for isolated deployments but increase the module's lifecycle scope.

Active-passive mode requires FortiOS HA configuration and probe responses in addition to Azure resources. Load balancer health probes, HA ports, floating IP, UDRs, SNAT/DNAT, NSGs, and symmetric traffic flow must be designed as one system.

## Credentials and Appliance Configuration

Terraform state can contain sensitive password and custom-data values. Prefer Key Vault-backed credentials, SSH administration, restricted management networks, and protected state.

This module provisions Azure infrastructure; it does not fully configure FortiOS policies, routing protocols, HA synchronization, licensing, FortiManager, or FortiAnalyzer.

## Naming and Tagging

The module derives VM, NIC, NSG, load balancer, and optional VNet names from `name_prefix` and instance keys. Explicit tags override inherited resource-group tags.

## Architecture

See [Architecture](docs/architecture.md) for the single and active-passive diagrams, network ownership modes, and operational boundaries.

## Testing

The unit tests use a mocked AzureRM provider:

```shell
terraform init -backend=false
terraform test
```

## Known Limitations

- FortiOS HA, routing, security policy, licenses, backups, upgrades, and monitoring are outside this module.
- Active-passive provisioning alone does not make the appliances healthy or failover-ready.
- Public load-balancer creation is not equivalent to safely publishing an application.
- Image availability, Marketplace terms, appliance boot, and runtime health cannot be verified by offline Terraform tests.

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
| [azurerm_lb.external](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb.internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb) | resource |
| [azurerm_lb_backend_address_pool.external](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_backend_address_pool.internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_backend_address_pool) | resource |
| [azurerm_lb_probe.external](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_probe.internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_probe) | resource |
| [azurerm_lb_rule.external](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_lb_rule.internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/lb_rule) | resource |
| [azurerm_linux_virtual_machine.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_backend_address_pool_association.external](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_interface_backend_address_pool_association.internal](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_backend_address_pool_association) | resource |
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.external_lb](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_credentials_key_vault_id"></a> [admin\_credentials\_key\_vault\_id](#input\_admin\_credentials\_key\_vault\_id) | Optional Azure Key Vault resource ID containing fallback FortiGate administrator credentials. | `string` | `""` | no |
| <a name="input_admin_password"></a> [admin\_password](#input\_admin\_password) | Optional FortiGate administrator password. Supply through a secret variable, not source control. | `string` | `""` | no |
| <a name="input_admin_password_secret_name"></a> [admin\_password\_secret\_name](#input\_admin\_password\_secret\_name) | Key Vault secret containing the fallback FortiGate administrator password. | `string` | `"azure-password"` | no |
| <a name="input_admin_ssh_key_secret_name"></a> [admin\_ssh\_key\_secret\_name](#input\_admin\_ssh\_key\_secret\_name) | Key Vault secret containing the fallback FortiGate SSH public key. | `string` | `"azureadmin-pubkey"` | no |
| <a name="input_admin_ssh_public_key"></a> [admin\_ssh\_public\_key](#input\_admin\_ssh\_public\_key) | Optional SSH public key for FortiGate administration. | `string` | `""` | no |
| <a name="input_admin_ssh_source_address_prefixes"></a> [admin\_ssh\_source\_address\_prefixes](#input\_admin\_ssh\_source\_address\_prefixes) | Trusted IPv4 addresses or CIDR prefixes allowed to administer FortiGate over TCP/22. | `list(string)` | `[]` | no |
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | FortiGate local administrator username. | `string` | `"azureuser"` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when name is not provided. | `string` | `"dev"` | no |
| <a name="input_architecture"></a> [architecture](#input\_architecture) | FortiGate architecture profile. single creates one VM; active-passive creates two VMs. | `string` | `"single"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | Zone assigned to each active-passive instance. Ignored by single architecture when single\_zone is empty. | `map(string)` | <pre>{<br>  "a": "1",<br>  "b": "2"<br>}</pre> | no |
| <a name="input_create_network_security_group"></a> [create\_network\_security\_group](#input\_create\_network\_security\_group) | Whether to create one NSG and associate it with interfaces where associate\_nsg is true. | `bool` | `true` | no |
| <a name="input_create_subnets"></a> [create\_subnets](#input\_create\_subnets) | Whether the module creates interface subnets. This must be true when create\_virtual\_network is true. | `bool` | `false` | no |
| <a name="input_create_virtual_network"></a> [create\_virtual\_network](#input\_create\_virtual\_network) | Whether to create a dedicated VNet for FortiGate. When false, virtual\_network\_name identifies a shared existing VNet. | `bool` | `false` | no |
| <a name="input_custom_data"></a> [custom\_data](#input\_custom\_data) | Optional FortiOS bootstrap configuration supplied as plain text and base64 encoded by the module. | `string` | `""` | no |
| <a name="input_external_load_balancer"></a> [external\_load\_balancer](#input\_external\_load\_balancer) | Optional external-side Standard Load Balancer for active-passive architecture. Public frontend creation is explicitly opt-in. | <pre>object({<br>    enabled                   = optional(bool, false)<br>    name                      = optional(string, "")<br>    interface_name            = optional(string, "external")<br>    create_public_ip          = optional(bool, false)<br>    public_ip_name            = optional(string, "")<br>    public_ip_domain_name     = optional(string, "")<br>    frontend_ip_address       = optional(string)<br>    frontend_allocation       = optional(string, "Dynamic")<br>    health_probe_port         = optional(number, 8008)<br>    health_probe_protocol     = optional(string, "Tcp")<br>    health_probe_request_path = optional(string)<br>    enable_ha_ports           = optional(bool, true)<br>    enable_floating_ip        = optional(bool, true)<br>    idle_timeout_in_minutes   = optional(number, 4)<br>  })</pre> | `{}` | no |
| <a name="input_image"></a> [image](#input\_image) | FortiGate Marketplace image reference. | <pre>object({<br>    publisher = string<br>    offer     = string<br>    sku       = string<br>    version   = string<br>  })</pre> | <pre>{<br>  "offer": "fortinet_fortigate-vm_v5",<br>  "publisher": "fortinet",<br>  "sku": "fortinet_fg-vm",<br>  "version": "latest"<br>}</pre> | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into FortiGate resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_interfaces"></a> [interfaces](#input\_interfaces) | Ordered FortiGate interfaces keyed by a stable interface name such as external, internal, ha, or management. | <pre>map(object({<br>    role                           = string<br>    subnet_id                      = optional(string, "")<br>    subnet_name                    = optional(string, "")<br>    address_prefixes               = optional(list(string), [])<br>    primary                        = optional(bool, false)<br>    enabled_architectures          = optional(set(string), ["single", "active-passive"])<br>    private_ip_address_allocation  = optional(string, "Static")<br>    private_ip_addresses           = optional(map(string), {})<br>    enable_ip_forwarding           = optional(bool, true)<br>    accelerated_networking_enabled = optional(bool, false)<br>    associate_nsg                  = optional(bool, true)<br>  }))</pre> | n/a | yes |
| <a name="input_internal_load_balancer"></a> [internal\_load\_balancer](#input\_internal\_load\_balancer) | Optional internal Standard Load Balancer for active-passive architecture. | <pre>object({<br>    enabled                   = optional(bool, false)<br>    name                      = optional(string, "")<br>    interface_name            = optional(string, "internal")<br>    frontend_ip_address       = optional(string)<br>    frontend_allocation       = optional(string, "Dynamic")<br>    health_probe_port         = optional(number, 8008)<br>    health_probe_protocol     = optional(string, "Tcp")<br>    health_probe_request_path = optional(string)<br>    enable_ha_ports           = optional(bool, true)<br>    enable_floating_ip        = optional(bool, true)<br>    idle_timeout_in_minutes   = optional(number, 4)<br>  })</pre> | `{}` | no |
| <a name="input_license_type"></a> [license\_type](#input\_license\_type) | FortiGate licensing model marker. The image and Marketplace plan must match this selection. | `string` | `"byol"` | no |
| <a name="input_load_balancer_frontend_zones"></a> [load\_balancer\_frontend\_zones](#input\_load\_balancer\_frontend\_zones) | Optional zones for load balancer frontends and a created public IP. Leave empty for a regional frontend. | `list(string)` | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for FortiGate resources. | `string` | n/a | yes |
| <a name="input_management_access_model"></a> [management\_access\_model](#input\_management\_access\_model) | Operational management model recorded in resource tags. | `string` | `"private"` | no |
| <a name="input_marketplace_plan"></a> [marketplace\_plan](#input\_marketplace\_plan) | Marketplace plan for the selected image. Set null only for an image that does not require a plan. | <pre>object({<br>    name      = string<br>    product   = string<br>    publisher = string<br>  })</pre> | <pre>{<br>  "name": "fortinet_fg-vm",<br>  "product": "fortinet_fortigate-vm_v5",<br>  "publisher": "fortinet"<br>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | Optional FortiGate resource name prefix override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Deprecated alias for name. Use name for the FortiGate VM, NIC, NSG, and load balancer name prefix. | `string` | `""` | no |
| <a name="input_network_security_group_name"></a> [network\_security\_group\_name](#input\_network\_security\_group\_name) | Optional NSG name. Defaults to nsg-<name\_prefix>. | `string` | `""` | no |
| <a name="input_network_security_rules"></a> [network\_security\_rules](#input\_network\_security\_rules) | NSG rules keyed by rule name. No inbound rules are created by default. | <pre>map(object({<br>    priority                     = number<br>    direction                    = string<br>    access                       = string<br>    protocol                     = string<br>    source_port_range            = optional(string)<br>    source_port_ranges           = optional(list(string))<br>    destination_port_range       = optional(string)<br>    destination_port_ranges      = optional(list(string))<br>    source_address_prefix        = optional(string)<br>    source_address_prefixes      = optional(list(string))<br>    destination_address_prefix   = optional(string)<br>    destination_address_prefixes = optional(list(string))<br>    description                  = optional(string)<br>  }))</pre> | `{}` | no |
| <a name="input_os_disk"></a> [os\_disk](#input\_os\_disk) | FortiGate OS disk settings. | <pre>object({<br>    caching              = optional(string, "ReadWrite")<br>    storage_account_type = optional(string, "Premium_LRS")<br>    disk_size_gb         = optional(number)<br>  })</pre> | `{}` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group for FortiGate compute and optional network resources. | `string` | n/a | yes |
| <a name="input_single_zone"></a> [single\_zone](#input\_single\_zone) | Optional availability zone for the single architecture. Leave empty for a regional VM. | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to module resources. | `map(string)` | `{}` | no |
| <a name="input_virtual_network_address_space"></a> [virtual\_network\_address\_space](#input\_virtual\_network\_address\_space) | Address space for the dedicated FortiGate VNet. Used only when create\_virtual\_network is true. | `list(string)` | `[]` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | VNet name. Identifies the shared VNet when create\_virtual\_network is false, or optionally overrides the dedicated VNet name when true. | `string` | `""` | no |
| <a name="input_virtual_network_resource_group_name"></a> [virtual\_network\_resource\_group\_name](#input\_virtual\_network\_resource\_group\_name) | Resource group containing or receiving the VNet. Defaults to resource\_group\_name. | `string` | `""` | no |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Azure VM size for each FortiGate instance. | `string` | `"Standard_F4s_v2"` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used when name is not provided. | `string` | `"network"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_architecture"></a> [architecture](#output\_architecture) | Effective FortiGate architecture profile. |
| <a name="output_external_load_balancer_id"></a> [external\_load\_balancer\_id](#output\_external\_load\_balancer\_id) | External-side load balancer ID, or null when disabled. |
| <a name="output_external_public_ip_id"></a> [external\_public\_ip\_id](#output\_external\_public\_ip\_id) | External load balancer public IP ID, or null when public frontend creation is disabled. |
| <a name="output_internal_load_balancer_frontend_ip"></a> [internal\_load\_balancer\_frontend\_ip](#output\_internal\_load\_balancer\_frontend\_ip) | Internal load balancer frontend private IP address. |
| <a name="output_internal_load_balancer_id"></a> [internal\_load\_balancer\_id](#output\_internal\_load\_balancer\_id) | Internal load balancer ID, or null when disabled. |
| <a name="output_network_interface_ids"></a> [network\_interface\_ids](#output\_network\_interface\_ids) | FortiGate NIC IDs keyed by <instance>-<interface>. |
| <a name="output_network_security_group_id"></a> [network\_security\_group\_id](#output\_network\_security\_group\_id) | Created NSG ID, or null when NSG creation is disabled. |
| <a name="output_private_ip_addresses"></a> [private\_ip\_addresses](#output\_private\_ip\_addresses) | FortiGate private IP addresses keyed by <instance>-<interface>. |
| <a name="output_public_frontend_enabled"></a> [public\_frontend\_enabled](#output\_public\_frontend\_enabled) | Whether this module creates a public frontend. |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | Effective subnet IDs keyed by interface name. |
| <a name="output_virtual_machine_ids"></a> [virtual\_machine\_ids](#output\_virtual\_machine\_ids) | FortiGate VM IDs keyed by instance suffix. |
| <a name="output_virtual_machine_names"></a> [virtual\_machine\_names](#output\_virtual\_machine\_names) | FortiGate VM names keyed by instance suffix. |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | Created dedicated VNet ID, or null when a shared VNet is used. |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | Effective VNet name containing the FortiGate subnets. |
<!-- END_TF_DOCS -->
