variable "resource_group_name" {
  type        = string
  description = "Resource group where the Databricks workspace will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "Optional Azure region for the Databricks workspace. Leave empty to use the target resource group's location."
  default     = ""
}

variable "name" {
  type        = string
  description = "Databricks workspace name. Leave empty to auto-generate a unique name."
  default     = ""
}

variable "sku" {
  type        = string
  description = "Databricks workspace SKU."
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium", "trial"], lower(var.sku))
    error_message = "sku must be standard, premium, or trial."
  }
}

variable "managed_resource_group_name" {
  type        = string
  description = "Optional managed resource group name for the Databricks workspace."
  default     = ""
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled on the Databricks workspace."
  default     = true
}

variable "network_security_group_rules_required" {
  type        = string
  description = "Network security group rules mode for VNet-injected workspaces."
  default     = "AllRules"

  validation {
    condition     = contains(["AllRules", "NoAzureDatabricksRules"], var.network_security_group_rules_required)
    error_message = "network_security_group_rules_required must be AllRules or NoAzureDatabricksRules."
  }
}

variable "customer_managed_key_enabled" {
  type        = bool
  description = "Whether customer-managed keys are enabled."
  default     = false
}

variable "infrastructure_encryption_enabled" {
  type        = bool
  description = "Whether infrastructure encryption is enabled."
  default     = false
}

variable "default_storage_firewall_enabled" {
  type        = bool
  description = "Whether the default storage account firewall is enabled."
  default     = false

  validation {
    condition     = var.default_storage_firewall_enabled ? trimspace(var.access_connector_id) != "" : true
    error_message = "access_connector_id must be set when default_storage_firewall_enabled is true."
  }
}

variable "access_connector_id" {
  type        = string
  description = "Optional Databricks access connector resource ID."
  default     = ""
}

variable "load_balancer_backend_address_pool_id" {
  type        = string
  description = "Optional load balancer backend address pool ID for secure cluster connectivity."
  default     = ""
}

variable "managed_disk_cmk_key_vault_id" {
  type        = string
  description = "Optional Key Vault ID for managed disk CMK."
  default     = ""
}

variable "managed_disk_cmk_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key ID for managed disk CMK."
  default     = ""
}

variable "managed_disk_cmk_rotation_to_latest_version_enabled" {
  type        = bool
  description = "Whether managed disk CMK should auto-rotate to the latest key version."
  default     = false

  validation {
    condition     = var.managed_disk_cmk_rotation_to_latest_version_enabled ? trimspace(var.managed_disk_cmk_key_vault_key_id) != "" : true
    error_message = "managed_disk_cmk_key_vault_key_id must be set when managed_disk_cmk_rotation_to_latest_version_enabled is true."
  }
}

variable "managed_services_cmk_key_vault_id" {
  type        = string
  description = "Optional Key Vault ID for managed services CMK."
  default     = ""
}

variable "managed_services_cmk_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key ID for managed services CMK."
  default     = ""
}

variable "custom_parameters" {
  description = "Optional Databricks custom parameters block for VNet injection, no-public-IP, and ML linkage scenarios."
  type = object({
    machine_learning_workspace_id                        = optional(string)
    nat_gateway_name                                     = optional(string)
    no_public_ip                                         = optional(bool)
    private_subnet_name                                  = optional(string)
    private_subnet_network_security_group_association_id = optional(string)
    public_subnet_name                                   = optional(string)
    public_subnet_network_security_group_association_id  = optional(string)
    virtual_network_id                                   = optional(string)
  })
  default = null

  validation {
    condition = var.custom_parameters == null || try(trimspace(var.custom_parameters.virtual_network_id), "") == "" || (
      try(trimspace(var.custom_parameters.public_subnet_name), "") != "" &&
      try(trimspace(var.custom_parameters.private_subnet_name), "") != "" &&
      try(trimspace(var.custom_parameters.public_subnet_network_security_group_association_id), "") != "" &&
      try(trimspace(var.custom_parameters.private_subnet_network_security_group_association_id), "") != ""
    )
    error_message = "When custom_parameters.virtual_network_id is set, public/private subnet names and NSG association IDs must also be provided."
  }
}

variable "enhanced_security_compliance" {
  description = "Optional enhanced security and compliance settings for the Databricks workspace."
  type = object({
    automatic_cluster_update_enabled      = optional(bool)
    compliance_security_profile_enabled   = optional(bool)
    compliance_security_profile_standards = optional(set(string))
    enhanced_security_monitoring_enabled  = optional(bool)
  })
  default = null
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Databricks workspace."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Databricks workspace."
  default     = []
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Databricks workspace."
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
  description = "A mapping of tags to assign to the Databricks workspace."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
