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
#     "Requested By"                      = "RITM???????"
#     "Provisioned By"                    = "admin@2join.us"
#     "Technical contact"                 = "admin@2join.us"
#     "Business contact"                  = "admin@2join.us"

#   }
# }


variable "location" {
  type        = string
  default     = "canadacentral"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Environment, the environment name such as 'sbx','test', 'prod', 'dev','qa'"
  validation {
    condition     = var.environment == null ? true : contains(["prod", "dev", "qa", "sbx", "test"], var.environment)
    error_message = "Only a valid azure names are expected here such as prod."
  }
}

variable "project" {
  type        = string
  default     = null
  description = "Default prefix of the resource group name that will be created."

  validation {
    condition     = var.project == null || try(trimspace(var.project), "") != ""
    error_message = "project cannot be an empty string."
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
  type = string

  validation {
    condition     = trimspace(var.iac_kv) != ""
    error_message = "iac_kv cannot be empty."
  }
}
variable "iac_st" {
  type = string

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
    condition     = trimspace(var.app_vm) != ""
    error_message = "app_vm cannot be empty."
  }
}
variable "app_env" {
  type = string

  validation {
    condition     = contains(["prod", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, dev, qa, sbx, poc, test."
  }
}

# variable "env" {
#   type        = string
#   description = "Environment name"
# }

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
  description = "Core count of the cluster which will execute data flow job: [8|16|32|48|144|272]"
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

# Log Analytics
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
  description = "The ID  and sub resource name of the Private Link Enabled Remote Resource which this Data Factory Private Endpoint should be connected to"
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
  type = string

  validation {
    condition     = trimspace(var.resource_group) != ""
    error_message = "resource_group cannot be empty."
  }
}


variable "app_admin_group" {
  type        = list(string)
  description = "The list of groups that will have administrative access to the resources."
  default     = ["BA-G-Azure-Owner-F"]
}
variable "app_user_group" {
  type        = list(string)
  description = "The list of groups that will have Reader access to the Azure Data Factory resource and remote access to the SHIR VM."
  default     = []
}

variable "vsts_configuration" {
  description = "Azure DevOps repo settings for ADF"
  type = object({
    account_name         = string # ADO organization name
    project_name         = string # ADO project
    repository_name      = string
    branch_name          = string
    root_folder          = string # e.g. "/"
    tenant_id            = string # your AAD tenant GUID
    collaboration_branch = optional(string)
  })
  default = {
    account_name         = "CCOE-Azure"
    project_name         = "CCoE-Infra-IaC"
    repository_name      = ""
    branch_name          = "adf_publish"
    root_folder          = "/"
    tenant_id            = "b0f3630d-e5de-4172-b492-0cf5cd387a41"
    collaboration_branch = "main"
  }
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

check "adf_input_consistency" {
  assert {
    condition     = !var.enable_private_endpoint || trimspace(var.private_dns_zone_id) != "" || trimspace(var.private_dns_zone_resource_group_name) != ""
    error_message = "When enable_private_endpoint is true, provide either private_dns_zone_id or private_dns_zone_resource_group_name for the existing privatelink.datafactory.azure.net zone."
  }

  assert {
    condition     = !var.self_hosted_integration_runtime_enabled || trimspace(var.app_vm) != ""
    error_message = "app_vm must be set when self_hosted_integration_runtime_enabled is true."
  }
}
