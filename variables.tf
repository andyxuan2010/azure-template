variable "module_plan_enabled" {
  description = "Per-module plan toggle map. Leave all values false for a parse-only harness, then turn on a module when you want to run a live plan for that specific module. The higher-level features map can also enable selected modules."
  type = object({
    acr                  = bool
    adf                  = bool
    aks                  = bool
    appregistration      = bool
    appservice           = bool
    appserviceplan       = bool
    applicationgateway   = bool
    automationaccount    = bool
    azure_ai_service     = bool
    azure_ai_search      = bool
    cosmosdb             = bool
    databricks           = bool
    eventhub             = bool
    firewall             = bool
    functionapp          = bool
    keyvault             = bool
    linuxvm              = bool
    loganalytics         = bool
    logicapp             = bool
    managedidentity      = bool
    managementgroups     = bool
    nsg                  = bool
    openai               = bool
    policy               = bool
    private_dns          = bool
    rg                   = bool
    roleassignments      = bool
    route_table          = bool
    servicebus           = bool
    sqldb                = bool
    sqlmi                = bool
    sqlmi_db             = bool
    storageaccount       = bool
    subscription_vending = bool
    vnet                 = bool
    winvm                = bool
  })
  default = {
    acr                  = false
    adf                  = false
    aks                  = false
    appregistration      = false
    appservice           = false
    appserviceplan       = false
    applicationgateway   = false
    automationaccount    = false
    azure_ai_service     = false
    azure_ai_search      = false
    cosmosdb             = false
    databricks           = false
    eventhub             = false
    firewall             = false
    functionapp          = false
    keyvault             = false
    linuxvm              = false
    loganalytics         = false
    logicapp             = false
    managedidentity      = false
    managementgroups     = false
    nsg                  = false
    openai               = false
    policy               = false
    private_dns          = false
    rg                   = false
    roleassignments      = false
    route_table          = false
    servicebus           = false
    sqldb                = false
    sqlmi                = false
    sqlmi_db             = false
    storageaccount       = false
    subscription_vending = false
    vnet                 = false
    winvm                = false
  }
}

variable "features" {
  description = "Optional high-level feature switches migrated from landingzone. Known keys include enable_management_group, enable_subscription_bootstrap, enable_private_dns, enable_adf, enable_azure_ai_search, enable_azure_ai_service, enable_openai, enable_acr, enable_app_services, enable_app_registration_for_appservice, enable_automation_accounts, enable_automation_ari_workloads, enable_linux_vm, enable_aks, and enable_sqldb. Unspecified keys fall back to module_plan_enabled."
  type        = map(bool)
  default     = {}
}

variable "subscription_id" {
  description = "Optional subscription GUID override used to build sample resource IDs. Leave empty to use the current Azure client context."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.subscription_id) == "" || can(regex("^[0-9a-fA-F-]{36}$", var.subscription_id))
    error_message = "subscription_id must be empty or a valid GUID."
  }
}

variable "tenant_id" {
  description = "Optional tenant GUID override used by sample identity-aware modules. Leave empty to use the current Azure client context."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.tenant_id) == "" || can(regex("^[0-9a-fA-F-]{36}$", var.tenant_id))
    error_message = "tenant_id must be empty or a valid GUID."
  }
}

variable "location" {
  description = "Primary Azure region used by the sample harness."
  type        = string
  default     = "canadacentral"
}

variable "environment" {
  description = "Environment suffix used in sample names."
  type        = string
  default     = "dev"
}

variable "workload" {
  description = "Workload prefix used in sample names."
  type        = string
  default     = "platform"

  validation {
    condition     = length(trimspace(var.workload)) > 0 && length(trimspace(var.workload)) <= 8
    error_message = "workload must be 1-8 characters."
  }
}

variable "shared_resource_group_name" {
  description = "Shared resource group name used by sample module inputs."
  type        = string
  default     = "rg-platform-dev"
}

variable "network_resource_group_name" {
  description = "Network resource group name used for sample subnet and VNet lookups."
  type        = string
  default     = "rg-platform-dev-network"
}

variable "private_dns_resource_group_name" {
  description = "Private DNS resource group name used by sample private endpoint inputs."
  type        = string
  default     = "rg-platform-dev"
}

variable "shared_vnet_name" {
  description = "Virtual network name used by sample subnet-based module inputs."
  type        = string
  default     = "vnet-platform-dev"
}

variable "app_subnet_name" {
  description = "Application subnet name used by VM, ADF, and VNet integration samples."
  type        = string
  default     = "snet-app"
}

variable "private_endpoint_subnet_name" {
  description = "Private endpoint subnet name used by sample private endpoint-enabled modules."
  type        = string
  default     = "snet-private-endpoints"
}

variable "firewall_subnet_name" {
  description = "Azure Firewall subnet name used by the firewall sample."
  type        = string
  default     = "AzureFirewallSubnet"
}

variable "shared_storage_account_name" {
  description = "Optional storage account name override used by sample modules that expect an existing storage account. Leave empty to derive st<workload><region><environment>."
  type        = string
  default     = ""
}

variable "shared_storage_blob_properties" {
  description = "Optional blob service protection settings passed to the shared storage account module. Set to null to leave blob_properties unmanaged by the root harness."
  type = object({
    versioning_enabled                     = optional(bool)
    change_feed_enabled                    = optional(bool)
    last_access_time_enabled               = optional(bool)
    delete_retention_policy_days           = optional(number)
    container_delete_retention_policy_days = optional(number)
    restore_policy_days                    = optional(number)
  })
  default = {
    versioning_enabled                     = true
    change_feed_enabled                    = true
    last_access_time_enabled               = true
    delete_retention_policy_days           = 7
    container_delete_retention_policy_days = 7
    restore_policy_days                    = 6
  }
}

variable "shared_key_vault_name" {
  description = "Optional Key Vault name override used by sample modules that expect an existing vault. Leave empty to derive kv<workload><region><environment>."
  type        = string
  default     = ""
}

variable "shared_log_analytics_name" {
  description = "Optional Log Analytics workspace name override used by diagnostic-enabled samples. Leave empty to derive law-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "shared_app_service_plan_name" {
  description = "Optional App Service Plan name override used by App Service, Function App, and Logic App samples. Leave empty to derive asp-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "shared_vm_name" {
  description = "Optional VM base name override used by the Linux VM, Windows VM, and ADF SHIR-oriented inputs. Leave empty to derive vm<workload><environment>."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.shared_vm_name) == "" || can(regex("^vm[a-zA-Z0-9-]{0,10}$", trimspace(var.shared_vm_name)))
    error_message = "shared_vm_name must be empty or start with vm and be at most 12 characters so the Windows VM module can append a 3-digit index and stay within the 15-character computer name limit."
  }
}

variable "azure-user" {
  description = "Local admin username passed into the linuxvm and winvm modules in the root harness."
  type        = string
  default     = ""
}

variable "azure-password" {
  description = "Local admin password passed into the linuxvm and winvm modules in the root harness."
  type        = string
  default     = ""
  sensitive   = true
}

variable "azure-ssh-key" {
  description = "SSH public key passed into the linuxvm module in the root harness."
  type        = string
  default     = ""
  sensitive   = true
}

variable "winvm_enable_domain_join" {
  description = "Whether the root harness should enable domain join for the winvm module."
  type        = bool
  default     = false
}

variable "winvm_domain_join_user" {
  description = "Domain join username override passed into the winvm module. Leave empty to use the configured Key Vault username secret."
  type        = string
  default     = ""
}

variable "winvm_domain_join_password" {
  description = "Domain join password override passed into the winvm module. Leave empty to use the configured Key Vault password secret."
  type        = string
  default     = ""
  sensitive   = true
}

variable "winvm_domain_join_username_secret_name" {
  description = "Key Vault secret name containing the winvm domain join username."
  type        = string
  default     = "domain-join-user"
}

variable "winvm_domain_join_password_secret_name" {
  description = "Key Vault secret name containing the winvm domain join password."
  type        = string
  default     = "domain-join-password"
  sensitive   = true
}

variable "linux_vm_datadog_api_key" {
  description = "Optional Datadog API key passed into the linuxvm module."
  type        = string
  default     = ""
  sensitive   = true
}

variable "shared_management_group_name" {
  description = "Management group name used by management group and policy samples."
  type        = string
  default     = "mg-platform-dev"
}

variable "sample_principal_object_id" {
  description = "Sample Entra object ID used in plan-only role assignment examples."
  type        = string
  default     = "00000000-0000-0000-0000-000000000001"

  validation {
    condition     = can(regex("^[0-9a-fA-F-]{36}$", var.sample_principal_object_id))
    error_message = "sample_principal_object_id must be a valid GUID."
  }
}

variable "app_admin_group" {
  description = "Optional Entra admin groups to pass into modules that support RBAC group assignments."
  type        = list(string)
  default     = []
}

variable "app_user_group" {
  description = "Optional Entra reader/user groups to pass into modules that support RBAC group assignments."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags shared across the sample harness."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Purpose     = "module-plan-harness"
    Workload    = "platform"
  }
}
