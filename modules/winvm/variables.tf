# variable "common_tags" {
#   type = map(any)

#   default = {
#     "Application Name"                  = "CCOE INFRA IAC"
#     "Application Owner"                 = "CCOE"
#     "AppSupport Team"                   = "CCOE"
#     "Approval Group"                    = "Need to fill"
#     "Business Owner"                    = "CCOE"
#     "Environment"                       = "prod"
#     "Infra Availability Classification" = "Bronze"
#     "InfraSupport Team"                 = "CCOE"
#     "Maintenance Window"                = "Need to fill"
#     "Project Name"                      = "CCOE INFRA IAC"
#     "Project Number"                    = "00000"
#     "RPO-RTO"                           = "48H/24H"
#     "Run Cost(Approved Run Budget)-USD" = "0"
#   }
# }

# #resource group specific tags
# variable "rg_tags" {
#   type = map(any)

#   default = {
#     "Application Name"                  = "Need to fill"
#     "Application Owner"                 = "Need to fill"
#     "AppSupport Team"                   = "Need to fill"
#     "Approval Group"                    = "Need to fill"
#     "Business Owner"                    = "Need to fill"
#     "Environment"                       = "Need to fill"
#     "Infra Availability Classification" = "Need to fill"
#     "InfraSupport Team"                 = "TCS"
#     "Maintenance Window"                = "Need to fill"
#     "Project Status"                    = "Need to fill"
#     "Project Name"                      = "Need to fill"
#     "Project Number"                    = "Need to fill"
#     "RPO-RTO"                           = "48H/24H"
#     "Run Cost(Approved Run Budget)-USD" = "50"
#     "IaC"                               = "Terraform"
#     "Requested By"                      = "RITM??????"
#     "Provisioned By"                    = "Need to fill"
#     "Technical contact"                 = "Need to fill"
#     "Business contact"                  = "Need to fill"
#   }
# }


variable "location" {
  default     = "eastus"
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
variable "app_vm" {
  type = string

  validation {
    condition     = can(regex("^vm[a-zA-Z0-9-]{0,13}$", trimspace(var.app_vm)))
    error_message = "app_vm must start with vm and be at most 15 characters using letters, numbers, or hyphens."
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
}

variable "enable_custom_script_extension" {
  description = "Whether to attach the CustomScriptExtension that runs the Windows bootstrap script."
  type        = bool
  default     = false
}

variable "enable_defender_performance_mode" {
  description = "Whether the Windows bootstrap script may temporarily adjust Microsoft Defender settings during heavy software installation steps."
  type        = bool
  default     = false
}
variable "domain_join_user" {
  type    = string
  default = "AERO\\\\b1001332a1"

  validation {
    condition     = trimspace(var.domain_join_user) != ""
    error_message = "domain_join_user cannot be empty."
  }
}
# variable "domain_join_pass" {
#   type      = string
#   sensitive = true
#   default   = ">1R%h.H4VdcB"
# }
variable "app_remote_group" {
  type    = list(string)
  default = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]

  validation {
    condition     = alltrue([for value in var.app_remote_group : trimspace(value) != ""])
    error_message = "app_remote_group cannot contain empty values."
  }
}
variable "app_admin_group" {
  type        = list(string)
  default     = ["7a958d36-a182-451e-8012-4e8fe9386dc7", "BA-G-Azure-Owner-F"]
  description = "AD groups granted Contributor on each VM resource, Contributor on each module-created NIC, and elevated guest login access where applicable."

  validation {
    condition     = alltrue([for value in var.app_admin_group : trimspace(value) != ""])
    error_message = "app_admin_group cannot contain empty values."
  }
}
variable "app_user_group" {
  type        = list(string)
  default     = []
  description = "AD groups granted Reader on each VM resource and standard guest login access where applicable."

  validation {
    condition     = alltrue([for value in var.app_user_group : trimspace(value) != ""])
    error_message = "app_user_group cannot contain empty values."
  }
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
}

check "winvm_input_consistency" {
  assert {
    condition     = !var.enable_shir || try(trimspace(var.adf_id), "") != ""
    error_message = "adf_id must be set when enable_shir is true."
  }

  assert {
    condition     = !var.enable_shir || var.enable_custom_script_extension
    error_message = "enable_custom_script_extension must be true when enable_shir is true, because SHIR bootstrap runs through the CustomScriptExtension."
  }

  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}
