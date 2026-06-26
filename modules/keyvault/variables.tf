variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the Key Vault will be deployed."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where to deploy the resource. If empty, the resource group's location is used."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Key Vault resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
}

variable "tenant_id" {
  type        = string
  description = "Tenant ID for the Key Vault. If empty, the current caller tenant is used."
  default     = ""

  validation {
    condition     = trimspace(var.tenant_id) == "" || can(regex("^[0-9a-fA-F-]{36}$", trimspace(var.tenant_id)))
    error_message = "tenant_id must be empty or a valid GUID."
  }
}

variable "name" {
  type        = string
  description = "Key Vault name. If empty, the module auto-generates a compliant name."
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.name))
    error_message = "name must be empty or 3-24 characters, start with a letter, end with a letter or digit, and contain only letters, digits, or hyphens."
  }
}

variable "app_env" {
  description = "Deployment environment (dev, staging, prod, sbx, test, qa)"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa"], var.app_env)
    error_message = "Environment must be one of: dev, staging, prod, sbx, test, qa."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Deprecated compatibility input. Supply workload tags explicitly through tags."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "sku_name" {
  type        = string
  description = "Key Vault SKU name."
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "sku_name must be either standard or premium."
  }
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Whether Azure RBAC is used instead of access policies."
  default     = true
}

variable "grant_current_caller_secrets_officer" {
  type        = bool
  description = "Whether to grant the current Terraform caller the Key Vault Secrets Officer role when full current-caller Key Vault roles are disabled."
  default     = false
}

variable "grant_current_caller_reader_roles" {
  type        = bool
  description = "Whether to grant the current Terraform caller the Key Vault Crypto User and Key Vault Secrets User roles."
  default     = false
}

variable "grant_current_terraform_service_principal_key_vault_roles" {
  type        = bool
  description = "Whether to assign Contributor and Key Vault Administrator to the current Terraform execution identity at the Key Vault scope for control-plane and data-plane access."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the Key Vault public endpoint is reachable."
  default     = false
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Whether purge protection is enabled."
  default     = true
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Soft delete retention in days."
  default     = 90

  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "soft_delete_retention_days must be between 7 and 90."
  }
}

variable "enabled_for_deployment" {
  type        = bool
  description = "Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the vault."
  default     = false
}

variable "enabled_for_disk_encryption" {
  type        = bool
  description = "Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable "enabled_for_template_deployment" {
  type        = bool
  description = "Whether Azure Resource Manager is permitted to retrieve secrets from the vault."
  default     = false
}

variable "contacts" {
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  description = "A list of contacts for the Key Vault certificates."
  default     = []

  validation {
    condition = alltrue([
      for contact in var.contacts :
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", contact.email))
    ])
    error_message = "All contacts must have a valid email address."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Entra group display names or object IDs that should receive Key Vault Administrator access. Prefer object IDs when display names are not unique."
  default     = null
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Entra group display names or object IDs that should receive Key Vault Secrets User access. Prefer object IDs when display names are not unique."
  default     = null
}

variable "enable_network_acls" {
  type        = bool
  description = "Whether to configure Key Vault network ACLs."
  default     = true
}

variable "network_acls_default_action" {
  type        = string
  description = "Default action for Key Vault network ACLs."
  default     = "Deny"

  validation {
    condition     = contains(["Allow", "Deny"], var.network_acls_default_action)
    error_message = "network_acls_default_action must be either Allow or Deny."
  }
}

variable "network_acls_bypass" {
  type        = string
  description = "Traffic classes to bypass the network ACLs."
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.network_acls_bypass)
    error_message = "network_acls_bypass must be either AzureServices or None."
  }
}

variable "network_acls_ip_rules" {
  type        = list(string)
  description = "IPv4 addresses or CIDR ranges allowed by the Key Vault network ACLs."
  default     = []

  validation {
    condition = alltrue([
      for value in var.network_acls_ip_rules :
      can(cidrhost(contains(value, "/") ? value : "${value}/32", 0))
    ])
    error_message = "network_acls_ip_rules entries must be valid IPv4 or IPv6 addresses or CIDR ranges."
  }
}

variable "network_acls_virtual_network_subnet_ids" {
  type        = list(string)
  description = "Subnet resource IDs allowed by the Key Vault network ACLs."
  default     = []

  validation {
    condition = alltrue([
      for value in var.network_acls_virtual_network_subnet_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", value))
    ])
    error_message = "network_acls_virtual_network_subnet_ids must contain valid subnet resource IDs."
  }
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Key Vault."
  default     = false
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint. If set, subnet lookup inputs are ignored."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_endpoint_subnet_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", trimspace(var.private_endpoint_subnet_id)))
    )
    error_message = "private_endpoint_subnet_id must be empty or a valid subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Existing subnet name used for private endpoint lookup when private_endpoint_subnet_id is not set."
  default     = null
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Existing virtual network name used for private endpoint subnet lookup."
  default     = null
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for private endpoint subnet lookup."
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional Private DNS zone ID to attach to the Key Vault private endpoint."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", trimspace(var.private_dns_zone_id)))
    )
    error_message = "private_dns_zone_id must be empty or a valid Private DNS zone resource ID."
  }
}

variable "private_dns_zone_name" {
  type        = string
  description = "Optional existing Private DNS zone name used to look up the Key Vault private endpoint DNS zone when private_dns_zone_id is not set."
  default     = null
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the Private DNS zone used for Key Vault private endpoint DNS lookup."
  default     = null
}

variable "enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the Key Vault."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID for diagnostics."
  default     = ""

  validation {
    condition = (
      trimspace(var.log_analytics_workspace_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", trimspace(var.log_analytics_workspace_id)))
    )
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = ["AuditEvent"]

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_categories :
      contains(["AuditEvent"], value)
    ])
    error_message = "diagnostic_log_categories must contain only supported Key Vault log categories."
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
    error_message = "diagnostic_metric_categories must contain only supported Key Vault metric categories."
  }
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "keyvault_input_consistency" {
  assert {
    condition = var.enable_rbac_authorization || (
      length(coalesce(var.app_admin_group, [])) == 0 &&
      length(coalesce(var.app_user_group, [])) == 0 &&
      !var.grant_current_caller_secrets_officer &&
      !var.grant_current_terraform_service_principal_key_vault_roles
    )
    error_message = "When enable_rbac_authorization is false, app_admin_group, app_user_group, grant_current_caller_secrets_officer, and grant_current_terraform_service_principal_key_vault_roles must be disabled because this module does not manage Key Vault access policies."
  }

  assert {
    condition = !var.enable_network_acls || (
      var.network_acls_default_action != "" &&
      var.network_acls_bypass != ""
    )
    error_message = "network ACL settings must be configured when enable_network_acls is true."
  }

  assert {
    condition = !var.enable_private_endpoint || (
      trimspace(var.private_endpoint_subnet_id) != "" || (
        try(trimspace(var.private_endpoint_subnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_vnet_name), "") != "" &&
        try(trimspace(var.private_endpoint_network_resource_group_name), "") != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_endpoint_subnet_id or provide private_endpoint_subnet_name, private_endpoint_vnet_name, and private_endpoint_network_resource_group_name."
  }

  assert {
    condition = !var.enable_private_endpoint || (
      trimspace(var.private_dns_zone_id) != "" || (
        try(trimspace(var.private_dns_zone_name), "") == "" &&
        try(trimspace(var.private_dns_zone_resource_group_name), "") == ""
        ) || (
        try(trimspace(var.private_dns_zone_name), "") != "" &&
        try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_dns_zone_id or provide both private_dns_zone_name and private_dns_zone_resource_group_name."
  }

  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }
}
