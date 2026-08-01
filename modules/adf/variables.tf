variable "name" {
  type        = string
  description = "Optional Data Factory name override. Leave empty to generate one from the naming convention."
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", trimspace(var.name)))
    error_message = "name must be empty or a valid 3-63 character Data Factory name."
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
  default     = ""
  description = "The Azure region for Data Factory. If empty, the target resource group's location is used."

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Data Factory resources."
  default     = true
}

variable "inherited_resource_group_tags" {
  type        = map(string)
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module falls back to reading the resource group."
  default     = null
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

variable "instance" {
  description = "Instance identifier used when name is not provided."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,12}$", trimspace(var.instance)))
    error_message = "instance must be 1-12 lowercase letters, numbers, or hyphens."
  }
}

# SHIR variables
variable "iac_rg" {
  type        = string
  description = "The resource group containing IaC dependencies (key vault, storage)"
  default     = ""
}

variable "iac_kv" {
  type        = string
  description = "The key vault for IaC secrets"
  default     = ""
}

variable "iac_st" {
  type        = string
  description = "The storage account for IaC"
  default     = ""
}

variable "app_rg" {
  type        = string
  description = "The application resource group name"
  default     = ""
}

variable "app_snet" {
  type        = string
  description = "The application subnet name used by SHIR or as the legacy private endpoint subnet lookup input."
  default     = ""
}

variable "app_vnet_rg" {
  type        = string
  description = "The application virtual network resource group used by SHIR or as the legacy private endpoint network lookup input."
  default     = ""
}

variable "app_vnet" {
  type        = string
  description = "The application virtual network name used by SHIR or as the legacy private endpoint virtual network lookup input."
  default     = ""
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

  validation {
    condition = (
      var.custom_adf_name == null ||
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", trimspace(var.custom_adf_name)))
    )
    error_message = "custom_adf_name must be null or a valid 3-63 character Data Factory name."
  }
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
  type        = map(string)
  description = "customized tags"
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "tags must contain only non-empty keys and values."
  }
}

variable "create_default_azure_integration_runtime" {
  type        = bool
  description = "Whether to create a configurable Azure Integration Runtime for Data Factory."
  default     = true
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
  type = list(object({
    object_id = string
    role      = string
  }))
  description = "Additional role assignments to create on the Data Factory resource."
  default     = []

  validation {
    condition = alltrue([
      for permission in var.permissions :
      can(regex("^[0-9a-fA-F-]{36}$", permission.object_id)) &&
      trimspace(permission.role) != ""
    ])
    error_message = "permissions entries must include a valid object_id GUID and non-empty role."
  }

  validation {
    condition = length(distinct([
      for permission in var.permissions :
      "${lower(permission.object_id)}:${lower(trimspace(permission.role))}"
    ])) == length(var.permissions)
    error_message = "permissions entries must use unique object_id and role combinations."
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

variable "shir_primary_authorization_key_secret_name" {
  type        = string
  description = "Key Vault secret name that receives the SHIR primary authorization key when SHIR is enabled."
  default     = "adf-ccoe-default-shir-key"

  validation {
    condition     = can(regex("^[0-9A-Za-z-]{1,127}$", trimspace(var.shir_primary_authorization_key_secret_name)))
    error_message = "shir_primary_authorization_key_secret_name must be a valid Key Vault secret name."
  }
}

variable "shir_secondary_authorization_key_secret_name" {
  type        = string
  description = "Second Key Vault secret name that receives the SHIR primary authorization key when SHIR is enabled, preserved for backward-compatible consumers."
  default     = "adf-ccoe-shir-default-key"

  validation {
    condition     = can(regex("^[0-9A-Za-z-]{1,127}$", trimspace(var.shir_secondary_authorization_key_secret_name)))
    error_message = "shir_secondary_authorization_key_secret_name must be a valid Key Vault secret name."
  }
}

variable "enable_key_vault_secret_user_role_assignment" {
  type        = bool
  description = "Whether to grant the Data Factory system-assigned identity Key Vault Secrets User on the IaC Key Vault."
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

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings. For backward compatibility, a non-empty log_analytics_workspace map also enables diagnostics."
  default     = false
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Leave empty to enable all categories returned by Azure Monitor."
  default     = []
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable. Leave empty to enable all metric categories returned by Azure Monitor."
  default     = []
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

  validation {
    condition = alltrue([
      for parameter in var.global_parameter :
      trimspace(parameter.name) != "" &&
      contains(["String", "Bool", "Int", "Float", "Object", "Array"], parameter.type)
    ])
    error_message = "global_parameter entries must include a non-empty name and a supported type: String, Bool, Int, Float, Object, or Array."
  }
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
    publishing_enabled   = optional(bool, true)
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
    publishing_enabled   = optional(bool, true)
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
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    )
    error_message = "private_dns_zone_id must be empty or a valid Private DNS zone resource ID."
  }
}

variable "private_endpoint_subnet_id" {
  description = "Optional subnet ID for the ADF private endpoint. If set, subnet lookup inputs are ignored."
  type        = string
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
  description = "Existing subnet name used for private endpoint lookup when private_endpoint_subnet_id is not set. Falls back to app_snet when empty."
  type        = string
  default     = ""
}

variable "private_endpoint_vnet_name" {
  description = "Existing virtual network name used for private endpoint subnet lookup. Falls back to app_vnet when empty."
  type        = string
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  description = "Resource group containing the virtual network used for private endpoint subnet lookup. Falls back to app_vnet_rg when empty."
  type        = string
  default     = ""
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
  description = "Specifies the type of Managed Service Identity that should be configured on this Data Factory. Possible values are None, SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["None", "SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be one of: None, SystemAssigned, UserAssigned, SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "Specifies a list of User Assigned Managed Identity IDs to be assigned to this Data Factory. Required if identity_type contains UserAssigned."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for identity_id in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", identity_id))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "purview_id" {
  description = "Specifies the ID of the Purview Account associated with this Data Factory."
  type        = string
  default     = null

  validation {
    condition = (
      var.purview_id == null ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Purview/accounts/.+$", var.purview_id))
    )
    error_message = "purview_id must be null or a valid Microsoft Purview account resource ID."
  }
}

variable "customer_managed_key_id" {
  description = "Specifies the Azure Key Vault Key ID to be used as the Customer Managed Key for Double Encryption."
  type        = string
  default     = null

  validation {
    condition = (
      var.customer_managed_key_id == null ||
      can(regex("^https://.+\\.vault\\.azure\\.net/keys/.+/.+$", var.customer_managed_key_id)) ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.KeyVault/vaults/.+/keys/.+/.+$", var.customer_managed_key_id))
    )
    error_message = "customer_managed_key_id must be null or a valid Key Vault key ID."
  }
}

variable "customer_managed_key_identity_id" {
  description = "User-assigned managed identity resource ID used to access the customer-managed key."
  type        = string
  default     = null

  validation {
    condition = (
      var.customer_managed_key_identity_id == null ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", var.customer_managed_key_identity_id))
    )
    error_message = "customer_managed_key_identity_id must be null or a valid user-assigned managed identity resource ID."
  }
}

check "adf_input_consistency" {
  assert {
    condition = !var.enable_private_endpoint || (
      trimspace(var.private_endpoint_subnet_id) != "" ||
      (
        trimspace(local.private_endpoint_subnet_name_final) != "" &&
        trimspace(local.private_endpoint_vnet_name_final) != "" &&
        trimspace(local.private_endpoint_rg_name_final) != ""
      )
    )
    error_message = "When enable_private_endpoint is true, set private_endpoint_subnet_id or provide private endpoint subnet, VNet, and network resource group lookup inputs."
  }

  assert {
    condition     = !var.enable_private_endpoint || trimspace(var.private_dns_zone_id) != "" || trimspace(var.private_dns_zone_resource_group_name) != ""
    error_message = "When enable_private_endpoint is true, provide either private_dns_zone_id or private_dns_zone_resource_group_name for the existing privatelink.datafactory.azure.net zone."
  }

  assert {
    condition = !var.self_hosted_integration_runtime_enabled || (
      trimspace(var.app_vm) != "" &&
      trimspace(var.app_rg) != "" &&
      trimspace(var.app_snet) != "" &&
      trimspace(var.app_vnet) != "" &&
      trimspace(var.app_vnet_rg) != "" &&
      trimspace(var.iac_rg) != "" &&
      trimspace(var.iac_kv) != "" &&
      trimspace(var.iac_st) != ""
    )
    error_message = "When self_hosted_integration_runtime_enabled is true, set app_vm, app_rg, app_snet, app_vnet, app_vnet_rg, iac_rg, iac_kv, and iac_st."
  }

  assert {
    condition     = var.vsts_configuration == null || var.github_configuration == null
    error_message = "You can only configure one of vsts_configuration or github_configuration."
  }

  assert {
    condition     = !contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) || length(var.identity_ids) > 0
    error_message = "identity_ids must be provided when identity_type contains UserAssigned."
  }

  assert {
    condition = var.customer_managed_key_id == null && var.customer_managed_key_identity_id == null ? true : (
      var.customer_managed_key_id != null &&
      var.customer_managed_key_identity_id != null &&
      contains(["UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type) &&
      contains(var.identity_ids, var.customer_managed_key_identity_id)
    )
    error_message = "Customer-managed keys require customer_managed_key_id, customer_managed_key_identity_id, and identity_type containing UserAssigned with the CMK identity in identity_ids."
  }

  assert {
    condition     = !var.enable_key_vault_secret_user_role_assignment || contains(["SystemAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "enable_key_vault_secret_user_role_assignment requires identity_type to include SystemAssigned."
  }

  assert {
    condition = !var.enable_key_vault_secret_user_role_assignment || (
      trimspace(var.iac_rg) != "" &&
      trimspace(var.iac_kv) != ""
    )
    error_message = "enable_key_vault_secret_user_role_assignment requires iac_rg and iac_kv."
  }

  assert {
    condition     = !(var.enable_diagnostics || length(var.log_analytics_workspace) > 0) || length(var.log_analytics_workspace) > 0
    error_message = "log_analytics_workspace must contain at least one workspace when diagnostics are enabled."
  }

  assert {
    condition     = length(var.managed_private_endpoint) == 0 || var.managed_virtual_network_enabled
    error_message = "managed_private_endpoint requires managed_virtual_network_enabled = true."
  }
}
