variable "location" {
  default     = "canadacentral"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa'"
  validation {
    condition     = var.app_env == null ? true : contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "Environment must be one of: prod, staging, dev, qa, sbx, poc, test."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Workload identifier used in tagging."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Windows VM resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
}

variable "azure-user" {
  type        = string
  default     = ""
  description = "Admin username for the Windows VM local administrator account. Used directly when non-empty; otherwise the module falls back to the configured Key Vault username secret."
}

variable "azure-password" {
  type        = string
  default     = ""
  description = "Admin password for the Windows VM local administrator account. Used directly when non-empty; otherwise the module falls back to the configured Key Vault password secret."
  sensitive   = true
}

variable "admin_credentials_key_vault_id" {
  type        = string
  default     = ""
  description = "Optional Azure Key Vault resource ID containing the Windows VM admin username and password secrets. When empty, the module falls back to the shared IaC Key Vault."

  validation {
    condition     = trimspace(var.admin_credentials_key_vault_id) == "" || can(regex("^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft\\.KeyVault/vaults/[^/]+$", trimspace(var.admin_credentials_key_vault_id)))
    error_message = "admin_credentials_key_vault_id must be a valid Azure Key Vault resource ID when provided."
  }
}

variable "admin_username_secret_name" {
  type        = string
  default     = "azure-user"
  description = "Key Vault secret name containing the Windows VM admin username. Used only when azure-user is empty."
}

variable "admin_password_secret_name" {
  type        = string
  default     = "azure-password"
  description = "Key Vault secret name containing the Windows VM admin password. Used only when azure-password is empty."
  sensitive   = true
}

variable "AADLoginForWindows" {
  description = "Should the VM be include the dependancy agent"
  default     = true
  type        = bool
}

variable "windows_image_publisher" {
  description = "Publisher of the Windows VM image."
  type        = string
  default     = "MicrosoftWindowsServer"

  validation {
    condition     = trimspace(var.windows_image_publisher) != ""
    error_message = "windows_image_publisher cannot be empty."
  }
}

# Popular Windows image options:
# Windows Server:
# publisher = "MicrosoftWindowsServer"
# offer     = "WindowsServer"
# sku       = "2022-Datacenter"
# sku       = "2022-datacenter-azure-edition"
# sku       = "2019-Datacenter"
# SQL Server on Windows:
# publisher = "MicrosoftSQLServer"
# offer     = "sql2022-ws2022"
# sku       = "standard-gen2"
# sku       = "enterprise-gen2"
# Windows 11 multi-session for AVD scenarios:
# publisher = "MicrosoftWindowsDesktop"
# offer     = "windows-11"
# sku       = "win11-22h2-avd"
# sku       = "win11-23h2-avd"
# Make sure windows_image_publisher, windows_image_offer, windows_image_sku, and windows_image_version match the same image family.
variable "windows_image_offer" {
  description = "Offer of the Windows VM image."
  type        = string
  default     = "WindowsServer"

  validation {
    condition     = trimspace(var.windows_image_offer) != ""
    error_message = "windows_image_offer cannot be empty."
  }
}

variable "windows_image_sku" {
  description = "SKU of the Windows VM image, for example 2022-Datacenter."
  type        = string
  default     = "2025-Datacenter"

  validation {
    condition     = trimspace(var.windows_image_sku) != ""
    error_message = "windows_image_sku cannot be empty."
  }
}

variable "windows_image_version" {
  description = "Version of the Windows VM image."
  type        = string
  default     = "latest"

  validation {
    condition     = trimspace(var.windows_image_version) != ""
    error_message = "windows_image_version cannot be empty."
  }
}

variable "disksize" {
  type    = number
  default = 0
}

variable "app_vm_number" {
  type    = number
  default = 1

  validation {
    condition     = var.app_vm_number >= 1
    error_message = "app_vm_number must be at least 1."
  }
}

variable "private_ip_addresses" {
  type        = list(string)
  default     = []
  description = "Optional static private IP addresses for the Windows VM NICs. Leave empty for dynamic private IP allocation. When provided, specify exactly one IP address per VM in app_vm_number order."

  validation {
    condition     = alltrue([for ip in var.private_ip_addresses : can(cidrhost("${ip}/32", 0))])
    error_message = "Each private_ip_addresses value must be a valid IPv4 address."
  }
}

variable "enable_zone_spread" {
  type        = bool
  default     = true
  description = "Whether to spread multi-VM deployments across availability zones by default. When enabled and app_vm_number is greater than 1, the module assigns zones in round-robin order from availability_zones."
}

variable "availability_zones" {
  type        = list(string)
  default     = ["1", "2", "3"]
  description = "Availability zones used for round-robin placement when enable_zone_spread is true and app_vm_number is greater than 1."

  validation {
    condition     = length(var.availability_zones) > 0 && alltrue([for zone in var.availability_zones : contains(["1", "2", "3"], trimspace(zone))])
    error_message = "availability_zones must contain one or more Azure availability zone identifiers from 1, 2, or 3."
  }
}

variable "app_vm_size" {
  type    = string
  default = "Standard_D2s_v3"

  validation {
    condition     = trimspace(var.app_vm_size) != ""
    error_message = "app_vm_size cannot be empty."
  }
}



# to define tfvars
variable "iac_rg" {
  type = string

  validation {
    condition     = trimspace(var.iac_rg) != ""
    error_message = "iac_rg cannot be empty."
  }
}
variable "iac_kv" {
  description = "Shared IaC Key Vault name containing Windows VM bootstrap secrets."
  type        = string
  default     = "kvplatformccdev"

  validation {
    condition     = trimspace(var.iac_kv) != ""
    error_message = "iac_kv cannot be empty."
  }
}
variable "iac_st" {
  description = "Shared IaC storage account name containing Windows VM bootstrap scripts."
  type        = string
  default     = "stplatformccdev"

  validation {
    condition     = trimspace(var.iac_st) != ""
    error_message = "iac_st cannot be empty."
  }
}

variable "localization_container_name" {
  description = "Blob container name in the shared IaC storage account that holds consumer-owned Windows localization scripts such as windows-localization.ps1 and <COMPUTERNAME>.ps1."
  type        = string
  default     = "localization"

  validation {
    condition     = trimspace(var.localization_container_name) != ""
    error_message = "localization_container_name cannot be empty."
  }
}
variable "app_rg" {
  type = string

  validation {
    condition     = trimspace(var.app_rg) != ""
    error_message = "app_rg cannot be empty."
  }
}
variable "app_snet" {
  type = string

  validation {
    condition     = trimspace(var.app_snet) != ""
    error_message = "app_snet cannot be empty."
  }
}
variable "app_vnet_rg" {
  type = string

  validation {
    condition     = trimspace(var.app_vnet_rg) != ""
    error_message = "app_vnet_rg cannot be empty."
  }
}
variable "app_vnet" {
  type = string

  validation {
    condition     = trimspace(var.app_vnet) != ""
    error_message = "app_vnet cannot be empty."
  }
}
variable "name" {
  type        = string
  default     = ""
  description = "Optional base Windows VM name override. Leave empty to generate a compact base name; environment/instance suffixes are appended by the module."

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-zA-Z0-9-]{1,12}$", trimspace(var.name)))
    error_message = "name must be empty or 1-12 characters using letters, numbers, or hyphens so the module can append a 3-digit instance suffix and keep Windows computer_name within 15 characters."
  }
}

variable "app_vm" {
  type        = string
  default     = ""
  description = "Deprecated alias for name. Use name for the base Windows VM name override."

  validation {
    condition     = trimspace(var.app_vm) == "" || can(regex("^[a-zA-Z0-9-]{1,12}$", trimspace(var.app_vm)))
    error_message = "app_vm must be empty or 1-12 characters using letters, numbers, or hyphens so the module can append a 3-digit instance suffix and keep Windows computer_name within 15 characters."
  }
}
# variable "app_env" {
#   type = string
# }

variable "domain" {
  type    = string
  default = "2join.us"
}
variable "enable_domain_join" {
  description = "Whether to join the Windows VM to the domain through JsonADDomainExtension."
  type        = bool
  default     = false

  validation {
    condition     = !(var.AADLoginForWindows && var.enable_domain_join)
    error_message = "AADLoginForWindows and enable_domain_join cannot both be true. Enable only one login/join method."
  }
}

variable "enable_custom_script_extension" {
  description = "Whether to attach the CustomScriptExtension that runs the Windows bootstrap script."
  type        = bool
  default     = false
}

variable "enable_virtual_machine_run_command" {
  description = "Whether to run the Windows bootstrap script through azurerm_virtual_machine_run_command instead of the CustomScriptExtension."
  type        = bool
  default     = false
}

variable "run_command_replace_trigger" {
  description = "Optional external trigger value that forces the Windows Run Command bootstrap resource to be replaced when changed."
  type        = string
  default     = ""
}

variable "enable_defender_performance_mode" {
  description = "Whether the Windows bootstrap script may temporarily adjust Microsoft Defender settings during heavy software installation steps."
  type        = bool
  default     = false
}
variable "domain_join_user" {
  type        = string
  default     = ""
  description = "Domain join username override in domain\\username format. Leave empty to use the configured Key Vault username secret."

  validation {
    condition     = var.domain_join_user == "" || can(regex("^.+\\\\.+$", trimspace(var.domain_join_user)))
    error_message = "domain_join_user must be empty or use domain\\username format."
  }
}

variable "domain_join_password" {
  type        = string
  default     = ""
  description = "Domain join password override. Leave empty to use the configured Key Vault password secret."
  sensitive   = true
}

variable "domain_join_username_secret_name" {
  type        = string
  default     = "domain-join-user"
  description = "Key Vault secret name containing the domain join username. Used only when domain_join_user is empty."
}

variable "domain_join_password_secret_name" {
  type        = string
  default     = "domain-join-password"
  description = "Key Vault secret name containing the domain join password. Used only when domain_join_password is empty."
  sensitive   = true
}
variable "app_admin_group" {
  type        = list(string)
  default     = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
  nullable    = true
  description = "Optional groups granted admin RBAC on each VM and NIC, and added to the VM Administrators group where Windows-resolvable. Null and empty entries are ignored."
}
variable "app_user_group" {
  type        = list(string)
  default     = []
  nullable    = true
  description = "Optional groups granted user RBAC on each VM, and added to the VM Remote Desktop Users group where Windows-resolvable. Null and empty entries are ignored."
}
variable "windows_group_domain_prefix" {
  type        = string
  default     = ""
  nullable    = false
  description = "Optional Windows domain or NetBIOS prefix applied to bare app_admin_group and app_user_group names before local group membership, Already-qualified names and SIDs are not changed."
}
variable "vm_remote_group" {
  type     = string
  default  = null
  nullable = true

  validation {
    condition     = var.vm_remote_group == null || try(trimspace(var.vm_remote_group), "") != ""
    error_message = "vm_remote_group must be null or a non-empty value."
  }
}
variable "vm_admin_group" {
  type     = string
  default  = null
  nullable = true

  validation {
    condition     = var.vm_admin_group == null || try(trimspace(var.vm_admin_group), "") != ""
    error_message = "vm_admin_group must be null or a non-empty value."
  }
}
variable "public_network_enabled" {
  type    = bool
  default = false
}

variable "rdp_source_address_prefixes" {
  type        = list(string)
  default     = []
  description = "Trusted IPv4 addresses or CIDR ranges allowed to reach RDP when public_network_enabled is true. Deliberately has no open-internet default."

  validation {
    condition = alltrue([
      for value in var.rdp_source_address_prefixes :
      can(cidrhost(strcontains(value, "/") ? value : "${value}/32", 0))
    ])
    error_message = "rdp_source_address_prefixes must contain valid IPv4 addresses or CIDR ranges."
  }
}

variable "enable_shir" {
  description = "Enable Self Hosted Integration Runtime bootstrap and related ADF RBAC wiring."
  type        = bool
  default     = false
}

variable "tags" {
  description = "customized tags"
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

# Optional diagnostics
variable "enable_diagnostics" {
  description = "Enable sending diagnostics to Log Analytics"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace resource ID for diagnostics"
  type        = string
  default     = ""
  validation {
    condition     = var.log_analytics_workspace_id == "" || can(regex("^/subscriptions/", var.log_analytics_workspace_id))
    error_message = "Workspace ID must be empty or a valid Azure resource ID."
  }
}

variable "adf_id" {
  type        = string
  description = "Resource ID of the target ADF for RBAC scope"
  default     = null

  validation {
    condition     = var.adf_id == null ? true : try(trimspace(var.adf_id), "") == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.DataFactory/factories/.+$", var.adf_id))
    error_message = "adf_id must be null, empty, or a valid Azure Data Factory resource ID."
  }
}
variable "patch_mode" {
  description = "Specifies the mode of VM Guest Patching to IaaS virtual machine or virtual machine scale set. Possible values are Manual, AutomaticByOS and AutomaticByPlatform."
  type        = string
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["Manual", "AutomaticByOS", "AutomaticByPlatform"], var.patch_mode)
    error_message = "patch_mode must be Manual, AutomaticByOS, or AutomaticByPlatform."
  }
}

check "winvm_input_consistency" {
  assert {
    condition     = !var.enable_shir || try(trimspace(var.adf_id), "") != ""
    error_message = "adf_id must be set when enable_shir is true."
  }

  assert {
    condition     = !var.enable_shir || var.enable_custom_script_extension || var.enable_virtual_machine_run_command
    error_message = "Either enable_custom_script_extension or enable_virtual_machine_run_command must be true when enable_shir is true, because SHIR bootstrap runs through the Windows bootstrap script."
  }

  assert {
    condition     = !(var.enable_custom_script_extension && var.enable_virtual_machine_run_command)
    error_message = "enable_custom_script_extension and enable_virtual_machine_run_command are mutually exclusive. Enable only one Windows bootstrap execution method."
  }

  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }

  assert {
    condition     = !var.public_network_enabled || length(var.rdp_source_address_prefixes) > 0
    error_message = "rdp_source_address_prefixes must contain at least one trusted source when public_network_enabled is true."
  }
}
