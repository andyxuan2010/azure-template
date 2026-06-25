variable "location" {
  type        = string
  default     = "canadacentral"
  description = "The Azure Region in which all resources in this example should be created."

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be a valid Azure region identifier."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa'"
  validation {
    condition     = var.app_env == null ? true : contains(["prod", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "Only a valid azure names are expected here such as prod."
  }
}

variable "workload" {
  type        = string
  default     = "ccoetest"
  description = "Workload identifier used in naming and tagging."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Linux VM resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
}

variable "tags" {
  description = "Custom tags applied to Linux VM resources. These override inherited resource group tags."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "admin_username" {
  type        = string
  default     = null
  nullable    = true
  description = "Optional admin username for the Linux VM local administrator account. When set, this overrides the Key Vault username secret. When unset, the module falls back to the configured Key Vault username secret and then to the module default."
}

variable "admin_password" {
  type        = string
  default     = null
  nullable    = true
  description = "Optional admin password for the Linux VM local administrator account. When set, this overrides the Key Vault password secret. When unset, the module falls back to the configured Key Vault password secret and then to the module default."
  sensitive   = true
}

variable "admin_ssh_key" {
  type        = string
  default     = null
  nullable    = true
  description = "Optional SSH public key for the Linux VM local administrator account. When set, this overrides the Key Vault SSH key secret. When unset, the module falls back to the configured Key Vault SSH key secret and then to the module default."
  sensitive   = true
}

variable "disable_password_authentication" {
  type        = bool
  default     = false
  description = "Whether to disable password authentication on the Linux VM and enforce SSH key authentication. When true, admin_username and admin_password inputs and their Key Vault fallbacks are ignored."
}

variable "admin_credentials_key_vault_id" {
  type        = string
  default     = ""
  description = "Optional Azure Key Vault resource ID containing the admin username, password, and SSH public key secrets used by this module."

  validation {
    condition     = trimspace(var.admin_credentials_key_vault_id) == "" || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.KeyVault/vaults/[^/]+$", trimspace(var.admin_credentials_key_vault_id)))
    error_message = "admin_credentials_key_vault_id must be a valid Azure Key Vault resource ID when provided."
  }
}

variable "admin_username_secret_name" {
  type        = string
  default     = "azure-user"
  description = "Key Vault secret name containing the Linux VM admin username. Used only when disable_password_authentication is false and admin_username is not set."
}

variable "admin_password_secret_name" {
  type        = string
  default     = "azure-password"
  description = "Key Vault secret name containing the Linux VM admin password. Used only when disable_password_authentication is false and admin_password is not set."
}

variable "admin_ssh_key_secret_name" {
  type        = string
  default     = "azureadmin-pubkey"
  description = "Key Vault secret name containing the Linux VM admin SSH public key. Used when admin_ssh_key is not set. The effective SSH key remains mandatory."
}

variable "post_init_script" {
  type        = string
  default     = ""
  description = "Optional inline bash content appended after the module's built-in init.sh bootstrap. This runs in the same custom_data/cloud-init execution path after the base init.sh logic finishes, before the optional Linux VM extension hook."
  sensitive   = true
}


variable "enable_entra_ssh_login" {
  type        = bool
  description = "Whether to enable Microsoft Entra ID SSH login on the Linux VMs via the AADSSHLoginForLinux extension."
  default     = false
}

variable "enable_linux_vm_extension" {
  type        = bool
  description = "Whether to enable the optional storage-backed localization CustomScript VM extension for Linux VMs. Disabled by default."
  default     = false
}

variable "enable_system_assigned_identity" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the Linux VMs. Defaults to true."
  default     = true
}

variable "localization_container_name" {
  type        = string
  description = "Blob container name in the shared IaC storage account that holds Linux VM localization scripts for the optional VM extension."
  default     = "localization"
}

variable "localization_os_script_name" {
  type        = string
  description = "The OS-level localization script blob name to download first when the optional Linux VM extension is enabled, for example ubuntu.sh or rhel.sh."
  default     = "ubuntu.sh"
}

variable "localization_vm_script_content" {
  type        = map(string)
  default     = {}
  sensitive   = true
  description = "Optional map of VM-specific localization blob content keyed by blob name, for example { \"myvm001.sh\" = file(\"scripts/myvm001.sh\") }. When provided, the module uploads these hostname-specific scripts to the localization container in the shared IaC storage account."
}

variable "enable_domain_join" {
  type        = bool
  description = "Whether to join the Linux VM to the domain during the bootstrap script. When false, the module skips the domain-join secret lookup and the bootstrap does not attempt AD join."
  default     = false
}

variable "datadog_api_key" {
  type        = string
  description = "Legacy Datadog API key input retained for backward compatibility."
  default     = ""
  sensitive   = true
}

variable "data_disk_size_gb" {
  type        = number
  default     = 0
  description = "Optional additional data disk size in GB. Set to 0 to skip the extra disk."

  validation {
    condition     = var.data_disk_size_gb >= 0
    error_message = "data_disk_size_gb must be zero or a positive number."
  }
}
variable "vm_count" {
  type        = number
  default     = 1
  description = "Number of Linux VMs to create."

  validation {
    condition     = var.vm_count >= 1
    error_message = "vm_count must be at least 1."
  }
}

variable "enable_zone_spread" {
  type        = bool
  default     = true
  description = "Whether to spread multi-VM deployments across availability zones by default. When enabled and vm_count is greater than 1, the module assigns zones in round-robin order from availability_zones."
}

variable "availability_zones" {
  type        = list(string)
  default     = ["1", "2", "3"]
  description = "Availability zones used for round-robin placement when enable_zone_spread is true and vm_count is greater than 1."

  validation {
    condition     = length(var.availability_zones) > 0 && alltrue([for zone in var.availability_zones : contains(["1", "2", "3"], trimspace(zone))])
    error_message = "availability_zones must contain one or more Azure availability zone identifiers from 1, 2, or 3."
  }
}

# Common VM sizes for vm_size:
# Pricing below is Linux pay-as-you-go in Canada Central as of 2026-03-22.
# Monthly price is an estimate based on 730 hours and excludes disks, networking, backup, tax, and discounts.
# Smaller dev/test VM sizes:
# Standard_B1ls    = 1 vCPU, 0.5 GiB RAM, 4.23 USD/month
# Standard_B1s     = 1 vCPU, 1 GiB RAM, 8.47 USD/month
# Standard_B1ms    = 1 vCPU, 2 GiB RAM, 16.79 USD/month
# Standard_B2as_v2 = 2 vCPU, 4 GiB RAM, 61.03 USD/month
# Standard_B2s     = 2 vCPU, 4 GiB RAM, 33.87 USD/month
# Standard_B2ms    = 2 vCPU, 8 GiB RAM, 67.74 USD/month
# General-purpose VM sizes:
# Standard_D2s_v3  = 2 vCPU, 8 GiB RAM, 81.03 USD/month
# Standard_D4s_v3  = 4 vCPU, 16 GiB RAM, 162.06 USD/month
# Standard_D8s_v3  = 8 vCPU, 32 GiB RAM, 324.12 USD/month
# Standard_D2s_v5  = 2 vCPU, 8 GiB RAM, 78.11 USD/month
# Standard_D4s_v5  = 4 vCPU, 16 GiB RAM, 156.22 USD/month
# Standard_D8s_v5  = 8 vCPU, 32 GiB RAM, 312.44 USD/month
# Memory-optimized VM sizes:
# Standard_E2s_v3  = 2 vCPU, 16 GiB RAM, 106.58 USD/month
# Standard_E4s_v3  = 4 vCPU, 32 GiB RAM, 213.16 USD/month
# Standard_E8s_v3  = 8 vCPU, 64 GiB RAM, 426.32 USD/month
# Standard_E2s_v5  = 2 vCPU, 16 GiB RAM, 100.74 USD/month
# Standard_E4s_v5  = 4 vCPU, 32 GiB RAM, 201.48 USD/month
# Standard_E8s_v5  = 8 vCPU, 64 GiB RAM, 402.96 USD/month
variable "vm_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "Azure VM size for each Linux VM."

  validation {
    condition     = trimspace(var.vm_size) != ""
    error_message = "vm_size cannot be empty."
  }
}

variable "enable_spot_instance" {
  type        = bool
  default     = false
  description = "Whether to create the Linux VMs as Azure Spot instances. When false, regular pay-as-you-go VMs are created."
}

variable "spot_eviction_policy" {
  type        = string
  default     = "Deallocate"
  description = "Eviction policy for Spot Linux VMs. Used only when enable_spot_instance is true. Valid values are Deallocate or Delete."

  validation {
    condition     = contains(["Deallocate", "Delete"], var.spot_eviction_policy)
    error_message = "spot_eviction_policy must be either Deallocate or Delete."
  }
}

variable "spot_max_bid_price" {
  type        = number
  default     = -1
  description = "Maximum hourly price for Spot Linux VMs. Used only when enable_spot_instance is true. Set to -1 to pay up to the current on-demand price."

  validation {
    condition     = var.spot_max_bid_price == -1 || var.spot_max_bid_price > 0
    error_message = "spot_max_bid_price must be -1 or a positive number."
  }
}

variable "image_publisher" {
  type        = string
  default     = "Canonical"
  description = "Publisher of the Linux VM image."
}

# Popular values for image_offer:
# Canonical:
# ubuntu-24_04-lts
# ubuntu-22_04-lts
# 0001-com-ubuntu-server-jammy
# Red Hat:
# RHEL
# RHEL-SAP
# SUSE:
# sles-15-sp5
# Debian:
# debian-12
# Oracle:
# oracle-linux
# Make sure image_publisher, image_offer, image_sku, and image_version match the same image family.
variable "image_offer" {
  type        = string
  default     = "ubuntu-24_04-lts"
  description = "Offer of the Linux VM image."
}

variable "image_sku" {
  type        = string
  default     = "server"
  description = "SKU of the Linux VM image."
}

variable "image_version" {
  type        = string
  default     = "latest"
  description = "Version of the Linux VM image."
}




# to define tfvars
variable "iac_rg" {
  type        = string
  description = "Resource group containing the shared IaC storage account and Key Vault."

  validation {
    condition     = trimspace(var.iac_rg) != ""
    error_message = "iac_rg cannot be empty."
  }
}
variable "iac_kv" {
  type        = string
  description = "Shared Key Vault name containing Linux VM secrets."

  validation {
    condition     = trimspace(var.iac_kv) != ""
    error_message = "iac_kv cannot be empty."
  }
}
variable "iac_kv_id" {
  type        = string
  description = "Shared Key Vault resource ID containing Linux VM secrets."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.KeyVault/vaults/[^/]+$", trimspace(var.iac_kv_id)))
    error_message = "iac_kv_id must be a valid Azure Key Vault resource ID."
  }
}
variable "iac_st" {
  type        = string
  description = "Shared storage account name containing bootstrap scripts."

  validation {
    condition     = trimspace(var.iac_st) != ""
    error_message = "iac_st cannot be empty."
  }
}
variable "iac_st_id" {
  type        = string
  description = "Shared storage account resource ID containing bootstrap scripts."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Storage/storageAccounts/[^/]+$", trimspace(var.iac_st_id)))
    error_message = "iac_st_id must be a valid Azure storage account resource ID."
  }
}
variable "iac_st_primary_blob_endpoint" {
  type        = string
  description = "Primary blob endpoint for the shared storage account containing bootstrap scripts."

  validation {
    condition     = can(regex("^https://.+/$", trimspace(var.iac_st_primary_blob_endpoint)))
    error_message = "iac_st_primary_blob_endpoint must be a valid HTTPS blob endpoint ending with '/'."
  }
}
variable "resource_group_name" {
  type        = string
  description = "Target resource group name for the Linux VM resources."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}
variable "subnet_name" {
  type        = string
  default     = ""
  description = "Legacy subnet name input retained for compatibility. Prefer subnet_id."
}
variable "subnet_id" {
  type        = string
  description = "Subnet resource ID used directly for the VM NICs."

  validation {
    condition     = can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+/subnets/[^/]+$", trimspace(var.subnet_id)))
    error_message = "subnet_id must be a valid Azure subnet resource ID."
  }
}
variable "vnet_resource_group_name" {
  type        = string
  default     = ""
  description = "Legacy virtual network resource group input retained for compatibility. Prefer vnet_id."
}
variable "vnet_name" {
  type        = string
  default     = ""
  description = "Legacy virtual network name input retained for compatibility. Prefer vnet_id."
}
variable "vnet_id" {
  type        = string
  default     = ""
  description = "Legacy virtual network resource ID input retained for compatibility. The module no longer resolves subnet IDs from VNet inputs."

  validation {
    condition     = trimspace(var.vnet_id) == "" || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.Network/virtualNetworks/[^/]+$", trimspace(var.vnet_id)))
    error_message = "vnet_id must be a valid Azure virtual network resource ID when provided."
  }
}
variable "vm_name" {
  type        = string
  description = "Base Linux VM name. Environment suffixes are appended by the module."

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,13}$", trimspace(var.vm_name)))
    error_message = "vm_name must be 1-13 characters using letters, numbers, or hyphens."
  }
}
# variable "app_env" {
#   type = string
# }

variable "domain" {
  type        = string
  default     = "2join.us"
  description = "AD domain used by the bootstrap script."
}
variable "domain_join_user" {
  type        = string
  default     = ""
  description = "Optional domain join user in domain\\username format. Leave empty to use domain_join_username_secret_name from Key Vault."

  validation {
    condition     = trimspace(var.domain_join_user) == "" || can(regex("^.+\\\\.+$", trimspace(var.domain_join_user)))
    error_message = "domain_join_user must be empty or use domain\\username format."
  }
}

variable "domain_join_username_secret_name" {
  type        = string
  default     = "domain-join-user"
  description = "Key Vault secret name containing the domain join username. Used only when domain_join_user is empty."
}

# variable "domain_join_pass" {
#   type      = string
#   sensitive = true
#   default   = ">1R%h.H4VdcB"
# }
variable "domain_join_ou" {
  type        = string
  default     = "azure"
  description = "Legacy domain join OU value retained for compatibility."
}

variable "app_admin_group" {
  type        = list(string)
  default     = []
  nullable    = true
  description = "Optional app admin group principal IDs granted Contributor on the VM resource and sudo/admin access inside the guest OS. Empty strings are ignored."

  validation {
    condition = alltrue([
      for value in coalesce(var.app_admin_group, []) :
      trimspace(value) == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))
    ])
    error_message = "app_admin_group must contain Microsoft Entra group object ID GUIDs."
  }
}
variable "app_user_group" {
  type        = list(string)
  default     = []
  nullable    = true
  description = "Optional app user group principal IDs granted Reader on the VM resource and standard SSH access inside the guest OS. Empty strings are ignored."

  validation {
    condition = alltrue([
      for value in coalesce(var.app_user_group, []) :
      trimspace(value) == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))
    ])
    error_message = "app_user_group must contain Microsoft Entra group object ID GUIDs."
  }
}

variable "bastion_resource_name" {
  type        = string
  default     = "bas-net-cc-prd"
  nullable    = true
  description = "Optional Azure Bastion host name used to grant Network Contributor access to app_admin_group and app_user_group when that RBAC is not already present. Set to null or empty string to skip Bastion RBAC."
}

variable "bastion_resource_group_name" {
  type        = string
  default     = "rg-ba-eus-prod-hub-network"
  nullable    = true
  description = "Optional resource group containing the Bastion host referenced by bastion_resource_name. Set to null or empty string only when bastion_resource_name is also null or empty."

  validation {
    condition     = try(trimspace(var.bastion_resource_name), "") == "" || try(trimspace(var.bastion_resource_group_name), "") != ""
    error_message = "bastion_resource_group_name cannot be null or empty when bastion_resource_name is set."
  }
}

variable "public_network_enabled" {
  type        = bool
  default     = false
  description = "Whether to create public IPs and NSGs for SSH access."
}

variable "public_ssh_source_address_prefixes" {
  type        = list(string)
  description = "Trusted IPv4/IPv6 addresses or CIDR prefixes allowed to SSH when public_network_enabled is true."
  default     = []

  validation {
    condition = alltrue([
      for value in var.public_ssh_source_address_prefixes :
      can(cidrhost(contains(value, "/") ? value : "${value}/32", 0))
    ])
    error_message = "public_ssh_source_address_prefixes must contain valid IP addresses or CIDR prefixes."
  }

  validation {
    condition     = length(var.public_ssh_source_address_prefixes) <= 100 && length(distinct(var.public_ssh_source_address_prefixes)) == length(var.public_ssh_source_address_prefixes)
    error_message = "public_ssh_source_address_prefixes must contain at most 100 unique entries."
  }
}

check "linuxvm_input_consistency" {
  assert {
    condition     = !var.public_network_enabled || length(var.public_ssh_source_address_prefixes) > 0
    error_message = "public_ssh_source_address_prefixes must contain at least one trusted source when public_network_enabled is true."
  }

  assert {
    condition     = !var.enable_entra_ssh_login || var.enable_system_assigned_identity
    error_message = "enable_entra_ssh_login requires enable_system_assigned_identity = true."
  }

  assert {
    condition     = !var.enable_linux_vm_extension || var.enable_system_assigned_identity
    error_message = "enable_linux_vm_extension requires enable_system_assigned_identity = true."
  }
}
