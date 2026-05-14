variable "resource_group_name" {
  type        = string
  description = "Resource group where the Azure AI Services account will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for the Azure AI Services account. Leave empty to use the target resource group's location."
  default     = ""
}

variable "name" {
  type        = string
  description = "Azure AI Services account name. Leave empty to auto-generate a unique name."
  default     = ""
}

variable "sku_name" {
  type        = string
  description = "SKU name for the Azure AI Services account."
  default     = "S0"
}

variable "custom_subdomain_name" {
  type        = string
  description = "Optional custom subdomain name for the Azure AI Services account."
  default     = ""
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

variable "fqdns" {
  type        = list(string)
  description = "Optional list of outbound FQDNs."
  default     = []
}

variable "project_management_enabled" {
  type        = bool
  description = "Whether project management is enabled."
  default     = false
}

variable "identity" {
  description = "Optional managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null
}

variable "customer_managed_key" {
  description = "Optional customer-managed key configuration."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null
}

variable "storage" {
  description = "Optional storage account attachment for Azure AI Services."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default = []
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
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure AI Services account."
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
  description = "Optional private DNS zone ID to attach to the private endpoint."
  default     = ""
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Azure AI Services account."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Azure AI Services account."
  default     = []
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure AI Services account."
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
  description = "A mapping of tags to assign to the Azure AI Services account."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
