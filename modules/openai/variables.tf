variable "resource_group_name" {
  type        = string
  description = "Resource group where the Azure OpenAI account will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for the Azure OpenAI account. Leave empty to use the target resource group's location."
  default     = ""
}

variable "name" {
  type        = string
  description = "Azure OpenAI account name. Leave empty to auto-generate a unique name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 2 &&
      length(trimspace(var.name)) <= 64 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.name)))
    )
    error_message = "When provided, name must be 2-64 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "sku_name" {
  type        = string
  description = "SKU name for the Azure OpenAI account."
  default     = "S0"

  validation {
    condition     = contains(["F0", "F1", "S", "S0", "S1", "S2", "S3", "S4", "S5", "S6", "P0", "P1", "P2", "E0", "DC0"], var.sku_name)
    error_message = "sku_name must be one of F0, F1, S, S0, S1, S2, S3, S4, S5, S6, P0, P1, P2, E0, or DC0."
  }
}

variable "custom_subdomain_name" {
  type        = string
  description = "Optional custom subdomain name for the Azure OpenAI account."
  default     = ""

  validation {
    condition = trimspace(var.custom_subdomain_name) == "" || (
      length(trimspace(var.custom_subdomain_name)) >= 2 &&
      length(trimspace(var.custom_subdomain_name)) <= 64 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.custom_subdomain_name)))
    )
    error_message = "When provided, custom_subdomain_name must be 2-64 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = true
}

variable "outbound_network_access_restricted" {
  type        = bool
  description = "Whether outbound network access is restricted."
  default     = false
}

variable "local_auth_enabled" {
  type        = bool
  description = "Whether local authentication keys are enabled."
  default     = true
}

variable "dynamic_throttling_enabled" {
  type        = bool
  description = "Whether dynamic throttling is enabled."
  default     = false
}

variable "custom_question_answering_search_service_id" {
  type        = string
  description = "Optional Azure AI Search service ID for question answering."
  default     = ""

  validation {
    condition = (
      trimspace(var.custom_question_answering_search_service_id) == "" &&
      trimspace(var.custom_question_answering_search_service_key) == ""
      ) || (
      trimspace(var.custom_question_answering_search_service_id) != "" &&
      trimspace(var.custom_question_answering_search_service_key) != ""
    )
    error_message = "custom_question_answering_search_service_id and custom_question_answering_search_service_key must be provided together."
  }
}

variable "custom_question_answering_search_service_key" {
  type        = string
  description = "Optional Azure AI Search service key for question answering."
  default     = ""
  sensitive   = true
}

variable "identity" {
  description = "Optional managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null

  validation {
    condition     = var.identity == null ? true : contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be one of SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }

  validation {
    condition = var.identity == null ? true : (
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type) ?
      length(try(var.identity.identity_ids, [])) > 0 :
      length(try(var.identity.identity_ids, [])) == 0
    )
    error_message = "identity.identity_ids must be provided for UserAssigned identities and omitted for SystemAssigned-only identities."
  }
}

variable "customer_managed_key" {
  description = "Optional customer-managed key configuration."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null

  validation {
    condition     = var.customer_managed_key == null ? true : trimspace(var.customer_managed_key.key_vault_key_id) != ""
    error_message = "customer_managed_key.key_vault_key_id cannot be empty when customer_managed_key is provided."
  }
}

variable "network_acls" {
  description = "Optional network ACL configuration."
  type = object({
    default_action = string
    bypass         = optional(string)
    ip_rules       = optional(set(string))
    virtual_network_rules = optional(set(object({
      subnet_id                            = string
      ignore_missing_vnet_service_endpoint = optional(bool)
    })))
  })
  default = null

  validation {
    condition     = var.network_acls == null ? true : contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "network_acls.default_action must be either Allow or Deny."
  }

  validation {
    condition     = var.network_acls == null ? true : try(var.network_acls.bypass, null) == null || contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "network_acls.bypass must be AzureServices or None when provided."
  }
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure OpenAI account."
  default     = false

  validation {
    condition = !var.enable_private_endpoint || trimspace(var.private_endpoint_subnet_id) != "" || (
      trimspace(var.private_endpoint_subnet_name) != "" &&
      trimspace(var.private_endpoint_vnet_name) != "" &&
      trimspace(var.private_endpoint_network_resource_group_name) != ""
    )
    error_message = "When enable_private_endpoint is true, provide private_endpoint_subnet_id or the subnet, virtual network, and network resource group names."
  }
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve the private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the private endpoint subnet."
  default     = ""
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional single private DNS zone ID to attach to the private endpoint. Use private_dns_zone_ids for new configurations."
  default     = ""
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Optional list of private DNS zone IDs to attach to the private endpoint."
  default     = []
}

variable "deployments" {
  description = "Optional Azure OpenAI model deployments keyed by deployment name."
  type = map(object({
    model_format               = string
    model_name                 = string
    model_version              = optional(string)
    sku_name                   = string
    sku_capacity               = optional(number)
    sku_family                 = optional(string)
    sku_size                   = optional(string)
    sku_tier                   = optional(string)
    dynamic_throttling_enabled = optional(bool)
    rai_policy_name            = optional(string)
    version_upgrade_option     = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for deployment_name, deployment in var.deployments : (
        trimspace(deployment_name) != "" &&
        trimspace(deployment.model_format) == "OpenAI" &&
        trimspace(deployment.model_name) != "" &&
        trimspace(deployment.sku_name) != "" &&
        (deployment.sku_capacity == null ? true : deployment.sku_capacity >= 1) &&
        (deployment.version_upgrade_option == null ? true : contains(["OnceNewDefaultVersionAvailable", "OnceCurrentVersionExpired", "NoAutoUpgrade"], deployment.version_upgrade_option))
      )
    ])
    error_message = "Each deployment must have a non-empty name, model_format must be OpenAI, model_name and sku_name must be non-empty, sku_capacity must be at least 1 when set, and version_upgrade_option must be OnceNewDefaultVersionAvailable, OnceCurrentVersionExpired, or NoAutoUpgrade when provided."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Azure OpenAI account."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Azure OpenAI account."
  default     = []
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure OpenAI account."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID used when diagnostics are enabled."
  default     = ""

  validation {
    condition     = var.enable_diagnostics ? trimspace(var.log_analytics_workspace_id) != "" : true
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = []
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Azure OpenAI account."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
