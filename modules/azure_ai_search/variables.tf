variable "resource_group_name" {
  type        = string
  description = "Resource group where the Azure AI Search service will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for the Azure AI Search service. Leave empty to use the target resource group's location."
  default     = ""
}

variable "name" {
  type        = string
  description = "Azure AI Search service name. Leave empty to auto-generate a unique name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 2 &&
      length(trimspace(var.name)) <= 60 &&
      can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", trimspace(var.name)))
    )
    error_message = "When provided, name must be 2-60 characters, use lowercase letters, numbers, or hyphens, and start and end with an alphanumeric character."
  }
}

variable "sku" {
  type        = string
  description = "SKU for the Azure AI Search service."
  default     = "standard"

  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], lower(trimspace(var.sku)))
    error_message = "sku must be one of free, basic, standard, standard2, standard3, storage_optimized_l1, or storage_optimized_l2."
  }
}

variable "replica_count" {
  type        = number
  description = "Replica count for the Azure AI Search service. Ignored for the free SKU."
  default     = 1

  validation {
    condition     = var.replica_count >= 1 && var.replica_count <= 12
    error_message = "replica_count must be between 1 and 12."
  }
}

variable "partition_count" {
  type        = number
  description = "Partition count for the Azure AI Search service. Ignored for the free SKU."
  default     = 1

  validation {
    condition     = contains([1, 2, 3, 4, 6, 12], var.partition_count)
    error_message = "partition_count must be one of 1, 2, 3, 4, 6, or 12."
  }
}

variable "hosting_mode" {
  type        = string
  description = "Hosting mode for the Azure AI Search service."
  default     = "default"

  validation {
    condition     = contains(["default", "highDensity"], trimspace(var.hosting_mode))
    error_message = "hosting_mode must be default or highDensity."
  }
}

variable "semantic_search_sku" {
  type        = string
  description = "Optional semantic ranker SKU for the Azure AI Search service."
  default     = ""

  validation {
    condition     = trimspace(var.semantic_search_sku) == "" || contains(["free", "standard"], lower(trimspace(var.semantic_search_sku)))
    error_message = "semantic_search_sku must be empty, free, or standard."
  }
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = true
}

variable "allowed_ips" {
  type        = list(string)
  description = "Optional list of public IP ranges allowed to access the Azure AI Search service."
  default     = []
}

variable "network_rule_bypass_option" {
  type        = string
  description = "Optional network rule bypass option."
  default     = "None"

  validation {
    condition     = contains(["None", "AzureServices"], trimspace(var.network_rule_bypass_option))
    error_message = "network_rule_bypass_option must be None or AzureServices."
  }
}

variable "local_authentication_enabled" {
  type        = bool
  description = "Whether API-key based local authentication is enabled."
  default     = true
}

variable "authentication_failure_mode" {
  type        = string
  description = "Optional authentication failure mode."
  default     = ""

  validation {
    condition     = trimspace(var.authentication_failure_mode) == "" || contains(["http401WithBearerChallenge", "http403"], trimspace(var.authentication_failure_mode))
    error_message = "authentication_failure_mode must be empty, http401WithBearerChallenge, or http403."
  }
}

variable "customer_managed_key_enforcement_enabled" {
  type        = bool
  description = "Whether customer-managed key enforcement is enabled on the Azure AI Search service."
  default     = false
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

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure AI Search service."
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

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Azure AI Search service."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Azure AI Search service."
  default     = []
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure AI Search service."
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
  description = "A mapping of tags to assign to the Azure AI Search service."
  default     = {}
}
