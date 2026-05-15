variable "name" {
  type        = string
  description = "Default prefix of the resource name that will be created."

  validation {
    condition     = trimspace(var.name) != ""
    error_message = "name cannot be an empty string."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa'"
  validation {
    condition     = contains(["prod", "dev", "qa", "sbx", "test", "poc"], var.app_env)
    error_message = "Only a valid azure names are expected here such as prod."
  }
}

variable "location" {
  type        = string
  default     = "canadacentral"
  description = "The Azure Region in which all resources in this example should be created."
}

# SHIR variables
variable "iac_rg" {
  type        = string
  description = "The resource group containing IaC dependencies (key vault, storage)"
  validation {
    condition     = trimspace(var.iac_rg) != ""
    error_message = "Cannot be empty."
  }
}

variable "iac_kv" {
  type        = string
  description = "The key vault for IaC secrets"
  validation {
    condition     = trimspace(var.iac_kv) != ""
    error_message = "Cannot be empty."
  }
}

variable "iac_st" {
  type        = string
  description = "The storage account for IaC"
  validation {
    condition     = trimspace(var.iac_st) != ""
    error_message = "Cannot be empty."
  }
}

variable "app_rg" {
  type        = string
  description = "The application resource group name"
  validation {
    condition     = trimspace(var.app_rg) != ""
    error_message = "Cannot be empty."
  }
}

variable "app_snet" {
  type        = string
  description = "The application subnet name"
  validation {
    condition     = trimspace(var.app_snet) != ""
    error_message = "Cannot be empty."
  }
}

variable "app_vnet_rg" {
  type        = string
  description = "The application vnet resource group"
  validation {
    condition     = trimspace(var.app_vnet_rg) != ""
    error_message = "Cannot be empty."
  }
}

variable "app_vnet" {
  type        = string
  description = "The application vnet name"
  validation {
    condition     = trimspace(var.app_vnet) != ""
    error_message = "Cannot be empty."
  }
}

variable "app_vm" {
  type        = string
  description = "The VM name used for Self Hosted Integration Runtime"
  default     = ""
}

variable "custom_adf_name" {
  type        = string
  description = "Specifies the name of the Data Factory"
  default     = null
}

variable "custom_default_ir_name" {
  type        = string
  description = "Specifies the name of the Managed Integration Runtime"
  default     = null
}

variable "custom_diagnostics_name" {
  type        = string
  description = "Specifies the name of Diagnostic Settings that monitors ADF"
  default     = null
}

variable "custom_shir_name" {
  type        = string
  description = "Specifies the name of Self Hosted Integration runtime"
  default     = null
}

variable "tags" {
  type        = map(any)
  description = "customized tags"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(tostring(k)) != "" && trimspace(tostring(v)) != ""])
    error_message = "tags must contain only non-empty keys and values."
  }
}

variable "public_network_enabled" {
  type        = bool
  description = "Is the Data Factory visible to the public network?"
  default     = false
}

variable "managed_virtual_network_enabled" {
  type        = bool
  description = "Is Managed Virtual Network enabled?"
  default     = true
}

variable "cleanup_enabled" {
  type        = bool
  description = "Cluster will not be recycled and it will be used in next data flow activity run until TTL (time to live) is reached if this is set as false"
  default     = true
}

variable "compute_type" {
  type        = string
  description = "Compute type of the cluster which will execute data flow job: [General|ComputeOptimized|MemoryOptimized]"
  default     = "General"

  validation {
    condition     = contains(["General", "ComputeOptimized", "MemoryOptimized"], var.compute_type)
    error_message = "compute_type must be one of: General, ComputeOptimized, MemoryOptimized."
  }
}

variable "core_count" {
  type        = number
  description = "Core count of the cluster which will execute data flow job: [8|16|32|48|80|144|272]"
  default     = 8

  validation {
    condition     = contains([8, 16, 32, 48, 80, 144, 272], var.core_count)
    error_message = "core_count must be one of: 8, 16, 32, 48, 80, 144, 272."
  }
}

variable "permissions" {
  type        = list(map(string))
  description = "Data Factory permission map"
  default = [
    {
      object_id = null
      role      = null
    }
  ]

  validation {
    condition = alltrue([
      for permission in var.permissions :
      (try(permission.object_id, null) == null && try(permission.role, null) == null) ||
      (
        try(permission.object_id, null) != null &&
        try(permission.role, null) != null &&
        try(trimspace(permission.object_id), "") != "" &&
        try(trimspace(permission.role), "") != ""
      )
    ])
    error_message = "permissions entries must either set both object_id and role or leave both null."
  }
}

variable "time_to_live_min" {
  type        = number
  description = "TTL for Integration runtime"
  default     = 15

  validation {
    condition     = var.time_to_live_min >= 0
    error_message = "time_to_live_min must be zero or greater."
  }
}

variable "virtual_network_enabled" {
  type        = bool
  description = "Managed Virtual Network for Integration runtime"
  default     = true
}

variable "self_hosted_integration_runtime_enabled" {
  type        = bool
  description = "Self Hosted Integration runtime"
  default     = false
}

variable "log_analytics_workspace" {
  type        = map(string)
  description = "Log Analytics Workspace Name to ID map"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.log_analytics_workspace : trimspace(k) != "" && can(regex("^/subscriptions/.+", v))])
    error_message = "log_analytics_workspace must map non-empty keys to valid Azure resource IDs."
  }
}

variable "analytics_destination_type" {
  type        = string
  default     = "Dedicated"
  description = "Log analytics destination type"

  validation {
    condition     = contains(["Dedicated", "AzureDiagnostics"], var.analytics_destination_type)
    error_message = "analytics_destination_type must be either Dedicated or AzureDiagnostics."
  }
}

variable "managed_private_endpoint" {
  type = set(object({
    name               = string
    target_resource_id = string
    subresource_name   = string
  }))
  description = "The ID and sub resource name of the Private Link Enabled Remote Resource"
  default     = []

  validation {
    condition = alltrue([
      for endpoint in var.managed_private_endpoint :
      trimspace(endpoint.name) != "" &&
      trimspace(endpoint.subresource_name) != "" &&
      can(regex("^/subscriptions/.+", endpoint.target_resource_id))
    ])
    error_message = "managed_private_endpoint entries must include a non-empty name, subresource_name, and valid target_resource_id."
  }
}

variable "global_parameter" {
  type = list(object({
    name  = string
    type  = optional(string, "String")
    value = string
  }))
  default     = []
  description = "Configuration of data factory global parameters"
}

variable "resource_group" {
  type        = string
  description = "The name of the resource group in which to create the data factory."

  validation {
    condition     = trimspace(var.resource_group) != ""
    error_message = "resource_group cannot be empty."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "The list of groups that will have administrative access to the resources."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "The list of groups that will have Reader access to the Azure Data Factory resource and remote access to the SHIR VM."
  default     = []
}

variable "vsts_configuration" {
  description = "Azure DevOps repo settings for ADF"
  type = object({
    account_name         = string
    project_name         = string
    repository_name      = string
    branch_name          = string
    root_folder          = string
    tenant_id            = string
    collaboration_branch = optional(string)
  })
  default = null
}

variable "github_configuration" {
  description = "GitHub repo settings for ADF"
  type = object({
    account_name         = string
    branch_name          = string
    git_url              = string
    repository_name      = string
    root_folder          = string
    collaboration_branch = optional(string)
  })
  default = null
}

variable "enable_private_endpoint" {
  description = "Whether to create the ADF control-plane private endpoint."
  type        = bool
  default     = false
}

variable "private_dns_zone_id" {
  description = "Optional existing private DNS zone ID for privatelink.datafactory.azure.net."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.private_dns_zone_id) == "" || can(regex("^/subscriptions/.+", var.private_dns_zone_id))
    error_message = "private_dns_zone_id must be empty or a valid Azure resource ID."
  }
}

variable "private_dns_zone_name" {
  description = "Private DNS zone name used when looking up the existing ADF private DNS zone."
  type        = string
  default     = "privatelink.datafactory.azure.net"
}

variable "private_dns_zone_resource_group_name" {
  description = "Resource group containing the existing ADF private DNS zone when private_dns_zone_id is not provided."
  type        = string
  default     = ""
}

variable "identity_type" {
  description = "Specifies the type of Managed Service Identity that should be configured on this Data Factory. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be one of: SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Data Factory. Required if identity_type contains UserAssigned."
  type        = list(string)
  default     = []
}

variable "purview_id" {
  description = "Specifies the ID of the Purview Account associated with this Data Factory."
  type        = string
  default     = null
}

variable "customer_managed_key_id" {
  description = "Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key for Double Encryption."
  type        = string
  default     = null
}

check "adf_input_consistency" {
  assert {
    condition     = !var.enable_private_endpoint || trimspace(var.private_dns_zone_id) != "" || trimspace(var.private_dns_zone_resource_group_name) != ""
    error_message = "When enable_private_endpoint is true, provide either private_dns_zone_id or private_dns_zone_resource_group_name for the existing privatelink.datafactory.azure.net zone."
  }

  assert {
    condition     = !var.self_hosted_integration_runtime_enabled || trimspace(var.app_vm) != ""
    error_message = "app_vm must be set when self_hosted_integration_runtime_enabled is true."
  }

  assert {
    condition     = var.vsts_configuration == null || var.github_configuration == null
    error_message = "You can only configure one of vsts_configuration or github_configuration."
  }

  assert {
    condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
    error_message = "identity_ids must be provided when identity_type contains UserAssigned."
  }
}
