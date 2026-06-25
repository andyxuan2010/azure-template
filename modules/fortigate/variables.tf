variable "architecture" {
  description = "FortiGate architecture profile. single creates one VM; active-passive creates two VMs."
  type        = string
  default     = "single"

  validation {
    condition     = contains(["single", "active-passive"], lower(trimspace(var.architecture)))
    error_message = "architecture must be single or active-passive."
  }
}

variable "resource_group_name" {
  description = "Resource group for FortiGate compute and optional network resources."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for FortiGate resources."
  type        = string

  validation {
    condition     = trimspace(var.location) != ""
    error_message = "location cannot be empty."
  }
}

variable "name_prefix" {
  description = "Prefix used for FortiGate VM, NIC, NSG, and load balancer names."
  type        = string
  default     = "fgt-vfirewall"

  validation {
    condition     = can(regex("^[A-Za-z0-9-]{1,54}$", trimspace(var.name_prefix)))
    error_message = "name_prefix must be 1-54 characters using letters, numbers, or hyphens."
  }
}

variable "license_type" {
  description = "FortiGate licensing model marker. The image and Marketplace plan must match this selection."
  type        = string
  default     = "byol"

  validation {
    condition     = contains(["byol", "payg"], lower(trimspace(var.license_type)))
    error_message = "license_type must be byol or payg."
  }
}

variable "vm_size" {
  description = "Azure VM size for each FortiGate instance."
  type        = string
  default     = "Standard_F4s_v2"
}

variable "availability_zones" {
  description = "Zone assigned to each active-passive instance. Ignored by single architecture when single_zone is empty."
  type        = map(string)
  default = {
    a = "1"
    b = "2"
  }

  validation {
    condition     = alltrue([for zone in values(var.availability_zones) : contains(["1", "2", "3"], zone)])
    error_message = "availability_zones values must be 1, 2, or 3."
  }
}

variable "single_zone" {
  description = "Optional availability zone for the single architecture. Leave empty for a regional VM."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.single_zone) == "" || contains(["1", "2", "3"], trimspace(var.single_zone))
    error_message = "single_zone must be empty, 1, 2, or 3."
  }
}

variable "load_balancer_frontend_zones" {
  description = "Optional zones for load balancer frontends and a created public IP. Leave empty for a regional frontend."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for zone in var.load_balancer_frontend_zones : contains(["1", "2", "3"], zone)])
    error_message = "load_balancer_frontend_zones values must be 1, 2, or 3."
  }
}

variable "admin_username" {
  description = "FortiGate local administrator username."
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Optional FortiGate administrator password. Supply through a secret variable, not source control."
  type        = string
  default     = ""
  sensitive   = true
}

variable "admin_ssh_public_key" {
  description = "Optional SSH public key for FortiGate administration."
  type        = string
  default     = ""
  sensitive   = true
}

variable "management_access_model" {
  description = "Operational management model recorded in resource tags."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "azure-bastion", "fortimanager"], lower(trimspace(var.management_access_model)))
    error_message = "management_access_model must be private, azure-bastion, or fortimanager."
  }
}

variable "image" {
  description = "FortiGate Marketplace image reference."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm"
    version   = "latest"
  }
}

variable "marketplace_plan" {
  description = "Marketplace plan for the selected image. Set null only for an image that does not require a plan."
  type = object({
    name      = string
    product   = string
    publisher = string
  })
  default = {
    name      = "fortinet_fg-vm"
    product   = "fortinet_fortigate-vm_v5"
    publisher = "fortinet"
  }
  nullable = true
}

variable "os_disk" {
  description = "FortiGate OS disk settings."
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Premium_LRS")
    disk_size_gb         = optional(number)
  })
  default = {}
}

variable "custom_data" {
  description = "Optional FortiOS bootstrap configuration supplied as plain text and base64 encoded by the module."
  type        = string
  default     = ""
  sensitive   = true
}

variable "create_subnets" {
  description = "Whether the module creates interface subnets. This must be true when create_virtual_network is true."
  type        = bool
  default     = false
}

variable "create_virtual_network" {
  description = "Whether to create a dedicated VNet for FortiGate. When false, virtual_network_name identifies a shared existing VNet."
  type        = bool
  default     = false
}

variable "virtual_network_name" {
  description = "VNet name. Identifies the shared VNet when create_virtual_network is false, or optionally overrides the dedicated VNet name when true."
  type        = string
  default     = ""
}

variable "virtual_network_resource_group_name" {
  description = "Resource group containing or receiving the VNet. Defaults to resource_group_name."
  type        = string
  default     = ""
}

variable "virtual_network_address_space" {
  description = "Address space for the dedicated FortiGate VNet. Used only when create_virtual_network is true."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for cidr in var.virtual_network_address_space : can(cidrhost(cidr, 0))])
    error_message = "virtual_network_address_space must contain valid CIDR blocks."
  }
}

variable "interfaces" {
  description = "Ordered FortiGate interfaces keyed by a stable interface name such as external, internal, ha, or management."
  type = map(object({
    role                           = string
    subnet_id                      = optional(string, "")
    subnet_name                    = optional(string, "")
    address_prefixes               = optional(list(string), [])
    primary                        = optional(bool, false)
    enabled_architectures          = optional(set(string), ["single", "active-passive"])
    private_ip_address_allocation  = optional(string, "Static")
    private_ip_addresses           = optional(map(string), {})
    enable_ip_forwarding           = optional(bool, true)
    accelerated_networking_enabled = optional(bool, false)
    associate_nsg                  = optional(bool, true)
  }))

  validation {
    condition     = length(var.interfaces) > 0
    error_message = "At least one interface must be defined."
  }

  validation {
    condition = alltrue([
      for interface in values(var.interfaces) :
      contains(["external", "internal", "ha", "management", "other"], lower(trimspace(interface.role)))
    ])
    error_message = "Each interface role must be external, internal, ha, management, or other."
  }

  validation {
    condition = alltrue([
      for interface in values(var.interfaces) :
      contains(["Static", "Dynamic"], interface.private_ip_address_allocation)
    ])
    error_message = "private_ip_address_allocation must be Static or Dynamic."
  }
}

variable "create_network_security_group" {
  description = "Whether to create one NSG and associate it with interfaces where associate_nsg is true."
  type        = bool
  default     = true
}

variable "network_security_group_name" {
  description = "Optional NSG name. Defaults to nsg-<name_prefix>."
  type        = string
  default     = ""
}

variable "network_security_rules" {
  description = "NSG rules keyed by rule name. No inbound rules are created by default."
  type = map(object({
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_port_ranges           = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
    description                  = optional(string)
  }))
  default = {}
}

variable "internal_load_balancer" {
  description = "Optional internal Standard Load Balancer for active-passive architecture."
  type = object({
    enabled                   = optional(bool, false)
    name                      = optional(string, "")
    interface_name            = optional(string, "internal")
    frontend_ip_address       = optional(string)
    frontend_allocation       = optional(string, "Dynamic")
    health_probe_port         = optional(number, 8008)
    health_probe_protocol     = optional(string, "Tcp")
    health_probe_request_path = optional(string)
    enable_ha_ports           = optional(bool, true)
    enable_floating_ip        = optional(bool, true)
    idle_timeout_in_minutes   = optional(number, 4)
  })
  default = {}
}

variable "external_load_balancer" {
  description = "Optional external-side Standard Load Balancer for active-passive architecture. Public frontend creation is explicitly opt-in."
  type = object({
    enabled                   = optional(bool, false)
    name                      = optional(string, "")
    interface_name            = optional(string, "external")
    create_public_ip          = optional(bool, false)
    public_ip_name            = optional(string, "")
    public_ip_domain_name     = optional(string, "")
    frontend_ip_address       = optional(string)
    frontend_allocation       = optional(string, "Dynamic")
    health_probe_port         = optional(number, 8008)
    health_probe_protocol     = optional(string, "Tcp")
    health_probe_request_path = optional(string)
    enable_ha_ports           = optional(bool, true)
    enable_floating_ip        = optional(bool, true)
    idle_timeout_in_minutes   = optional(number, 4)
  })
  default = {}
}

variable "tags" {
  description = "Tags applied to module resources."
  type        = map(string)
  default     = {}
}

check "interface_subnet_inputs" {
  assert {
    condition = alltrue([
      for interface in values(var.interfaces) :
      var.create_subnets
      ? trimspace(interface.subnet_name) != "" && length(interface.address_prefixes) > 0
      : trimspace(interface.subnet_id) != ""
    ])
    error_message = "Each interface must supply subnet_name/address_prefixes when create_subnets is true, or subnet_id when it is false."
  }
}

check "virtual_network_inputs" {
  assert {
    condition = var.create_virtual_network ? (
      var.create_subnets && length(var.virtual_network_address_space) > 0
      ) : (
      !var.create_subnets || trimspace(var.virtual_network_name) != ""
    )
    error_message = "A dedicated VNet requires create_subnets = true and virtual_network_address_space; shared-VNet subnet creation requires virtual_network_name."
  }
}

check "enabled_interface_primary" {
  assert {
    condition = length([
      for interface in values(var.interfaces) : interface
      if contains(interface.enabled_architectures, lower(trimspace(var.architecture))) && interface.primary
    ]) == 1
    error_message = "Exactly one interface enabled for the selected architecture must set primary = true."
  }
}

check "load_balancer_architecture" {
  assert {
    condition     = lower(trimspace(var.architecture)) == "active-passive" || (!var.internal_load_balancer.enabled && !var.external_load_balancer.enabled)
    error_message = "Load balancers can only be enabled with architecture = active-passive."
  }
}

check "internal_load_balancer_interface" {
  assert {
    condition     = !var.internal_load_balancer.enabled || contains(keys(var.interfaces), var.internal_load_balancer.interface_name)
    error_message = "internal_load_balancer.interface_name must reference an interfaces key."
  }
}

check "external_load_balancer_interface" {
  assert {
    condition     = !var.external_load_balancer.enabled || contains(keys(var.interfaces), var.external_load_balancer.interface_name)
    error_message = "external_load_balancer.interface_name must reference an interfaces key."
  }
}
