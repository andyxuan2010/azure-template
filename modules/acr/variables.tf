variable "resource_group_name" {
  type        = string
  description = "Existing resource group name where the Azure Container Registry will be created."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Azure region for the Azure Container Registry."

  validation {
    condition     = trimspace(var.location) != "" && can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Azure Container Registry name. Leave empty to generate a compliant name."
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-z0-9]{5,50}$", lower(trimspace(var.name))))
    error_message = "name must be empty or 5-50 lowercase alphanumeric characters."
  }
}

variable "sku" {
  type        = string
  description = "SKU for the Azure Container Registry."
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Whether the admin user is enabled for the registry."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for the registry."
  default     = false
}

variable "anonymous_pull_enabled" {
  type        = bool
  description = "Whether anonymous pull access is enabled."
  default     = false

  validation {
    condition     = !var.anonymous_pull_enabled || contains(["Standard", "Premium"], var.sku)
    error_message = "anonymous_pull_enabled is only supported with Standard or Premium SKU."
  }
}

variable "data_endpoint_enabled" {
  type        = bool
  description = "Whether dedicated data endpoints are enabled."
  default     = false

  validation {
    condition     = !var.data_endpoint_enabled || var.sku == "Premium"
    error_message = "data_endpoint_enabled is only supported with Premium SKU."
  }
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the registry."
  default     = false
}

variable "enable_network_rule_set" {
  type        = bool
  description = "Whether to configure ACR network rules."
  default     = false

  validation {
    condition     = !var.enable_network_rule_set || var.sku == "Premium"
    error_message = "enable_network_rule_set is only supported with Premium SKU."
  }
}

variable "network_rule_bypass_option" {
  type        = string
  description = "Bypass option for the ACR network rule set."
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.network_rule_bypass_option)
    error_message = "network_rule_bypass_option must be AzureServices or None."
  }
}

variable "network_rule_default_action" {
  type        = string
  description = "Default action for the ACR network rule set."
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_rule_default_action)
    error_message = "network_rule_default_action must be Allow or Deny."
  }
}

variable "network_rule_ip_rules" {
  type        = list(string)
  description = "Optional list of allowed public IP CIDR ranges for ACR network rules."
  default     = []

  validation {
    condition = alltrue([
      for value in var.network_rule_ip_rules :
      can(cidrhost(contains(value, "/") ? value : "${value}/32", 0))
    ])
    error_message = "network_rule_ip_rules entries must be valid IPv4/IPv6 addresses or CIDR ranges."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Entra groups that receive Contributor on the registry resource. Values may be display names or object IDs."
  default     = null
}

variable "app_user_group" {
  type        = list(string)
  description = "Entra groups that receive Reader on the registry resource. Values may be display names or object IDs."
  default     = null
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the registry."
  default     = false

  validation {
    condition     = !var.enable_private_endpoint || var.sku == "Premium"
    error_message = "enable_private_endpoint is only supported with Premium SKU."
  }

  validation {
    condition = !var.enable_private_endpoint || (
      try(trimspace(var.private_endpoint_subnet_id), "") != "" || (
        try(trimspace(var.private_endpoint_subnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_endpoint_subnet_id or provide private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name."
  }
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint. Leave empty to resolve it from subnet/vnet/resource group names."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_endpoint_subnet_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.private_endpoint_subnet_id))
    )
    error_message = "private_endpoint_subnet_id must be empty or a valid subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Private endpoint subnet name used when private_endpoint_subnet_id is empty."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Private endpoint virtual network name used when private_endpoint_subnet_id is empty."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the private endpoint virtual network when resolving the subnet by name."
  default     = ""

  validation {
    condition = (
      (trimspace(var.private_endpoint_subnet_name) == "" && trimspace(var.private_endpoint_vnet_name) == "" && trimspace(var.private_endpoint_network_resource_group_name) == "") ||
      (trimspace(var.private_endpoint_subnet_name) != "" && trimspace(var.private_endpoint_vnet_name) != "" && trimspace(var.private_endpoint_network_resource_group_name) != "")
    )
    error_message = "private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name must either all be set or all be empty."
  }
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone ID for the registry private endpoint."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    )
    error_message = "private_dns_zone_id must be empty or a valid Private DNS zone resource ID."
  }
}

variable "private_dns_zone_name" {
  type        = string
  description = "Optional existing Private DNS zone name used to look up the registry private endpoint DNS zone when private_dns_zone_id is not set."
  default     = ""
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the Private DNS zone used for ACR private endpoint DNS lookup."
  default     = ""

  validation {
    condition = (
      (trimspace(var.private_dns_zone_name) == "" && trimspace(var.private_dns_zone_resource_group_name) == "") ||
      (trimspace(var.private_dns_zone_name) != "" && trimspace(var.private_dns_zone_resource_group_name) != "")
    )
    error_message = "private_dns_zone_name and private_dns_zone_resource_group_name must either both be set or both be empty."
  }
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create a diagnostic setting for the registry."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID used when diagnostics are enabled."
  default     = ""

  validation {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be provided when enable_diagnostics is true."
  }

  validation {
    condition = (
      trimspace(var.log_analytics_workspace_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      contains(["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"], value)
    ])
    error_message = "diagnostic_log_categories must contain only supported ACR log categories."
  }
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_metric_categories :
      contains(["AllMetrics"], value)
    ])
    error_message = "diagnostic_metric_categories must contain only supported ACR metric categories."
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to resources created by this module."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "acr_input_consistency" {
  assert {
    condition = !var.enable_private_endpoint || (
      trimspace(var.private_dns_zone_id) != "" || (
        trimspace(var.private_dns_zone_name) == "" &&
        trimspace(var.private_dns_zone_resource_group_name) == ""
        ) || (
        trimspace(var.private_dns_zone_name) != "" &&
        trimspace(var.private_dns_zone_resource_group_name) != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_dns_zone_id or provide both private_dns_zone_name and private_dns_zone_resource_group_name."
  }
}
