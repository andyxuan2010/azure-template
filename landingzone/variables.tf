variable "location" {
  description = "Azure region for the landing zone."
  type        = string
  default     = "canadacentral"
}

variable "workload" {
  description = "Short workload or platform identifier used in generated names."
  type        = string
  default     = "lzdemo"
}

variable "environment" {
  description = "Environment suffix used in generated names."
  type        = string
  default     = "dev"
}

variable "enable_management_group" {
  description = "Whether to create a management group in the example."
  type        = bool
  default     = false
}

variable "management_group_name" {
  description = "Optional override for the management group ID."
  type        = string
  default     = ""
}

variable "management_group_display_name" {
  description = "Optional override for the management group display name."
  type        = string
  default     = ""
}

variable "management_group_parent_management_group_id" {
  description = "Optional parent management group resource ID."
  type        = string
  default     = ""
}

variable "management_group_children" {
  description = "Child management groups created under the landing zone root management group."
  type = map(object({
    display_name = string
  }))
  default = {
    platform = {
      display_name = "Platform"
    }
    connectivity = {
      display_name = "Connectivity"
    }
    identity = {
      display_name = "Identity"
    }
    landingzones = {
      display_name = "Landing Zones"
    }
    sandboxes = {
      display_name = "Sandboxes"
    }
  }
}

variable "enable_subscription_bootstrap" {
  description = "Whether to use subscription_vending in the example."
  type        = bool
  default     = false
}

variable "subscription_alias_enabled" {
  description = "Whether the landing zone should create a new subscription alias."
  type        = bool
  default     = false
}

variable "subscription_alias_name" {
  description = "Subscription alias name when subscription_alias_enabled is true."
  type        = string
  default     = ""
}

variable "subscription_name" {
  description = "Display name for the subscription bootstrap example."
  type        = string
  default     = "platform-landingzone-dev"
}

variable "billing_scope_id" {
  description = "Billing scope ID when creating a new subscription alias."
  type        = string
  default     = ""
}

variable "existing_subscription_id" {
  description = "Existing subscription resource ID used when bootstrapping an existing subscription."
  type        = string
  default     = ""
}

variable "subscription_management_group_id" {
  description = "Existing management group resource ID to use when enable_management_group is false."
  type        = string
  default     = ""
}

variable "subscription_resource_provider_registrations" {
  description = "Resource providers to register when subscription bootstrap is enabled."
  type        = list(string)
  default = [
    "Microsoft.Network",
    "Microsoft.KeyVault",
    "Microsoft.Storage",
    "Microsoft.Web",
    "Microsoft.Insights",
    "Microsoft.DataFactory",
    "Microsoft.Databricks"
  ]
}

variable "hierarchy_subscriptions" {
  description = "Optional subscription hierarchy entries keyed by child management group name."
  type = map(object({
    subscription_name          = string
    existing_subscription_id   = string
    subscription_alias_enabled = optional(bool, false)
    subscription_alias_name    = optional(string, "")
    billing_scope_id           = optional(string, "")
  }))
  default = {
    platform = {
      subscription_name        = "platform-shared-dev"
      existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000010"
    }
    connectivity = {
      subscription_name        = "platform-connectivity-dev"
      existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000011"
    }
    identity = {
      subscription_name        = "platform-identity-dev"
      existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000012"
    }
    landingzones = {
      subscription_name        = "landingzones-dev"
      existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000013"
    }
    sandboxes = {
      subscription_name        = "sandboxes-dev"
      existing_subscription_id = "/subscriptions/00000000-0000-0000-0000-000000000014"
    }
  }
}

variable "resource_group_name" {
  description = "Optional override for the landing zone resource group name."
  type        = string
  default     = ""
}

variable "hub_vnet_name" {
  description = "Optional override for the hub virtual network name."
  type        = string
  default     = ""
}

variable "spoke_vnet_name" {
  description = "Optional override for the spoke virtual network name."
  type        = string
  default     = ""
}

variable "nsg_name" {
  description = "Optional override for the landing zone NSG name."
  type        = string
  default     = ""
}

variable "managed_identity_name" {
  description = "Optional override for the landing zone user-assigned managed identity name."
  type        = string
  default     = ""
}

variable "storage_account_name" {
  description = "Optional override for the landing zone storage account name."
  type        = string
  default     = ""
}

variable "key_vault_name" {
  description = "Optional override for the landing zone Key Vault name."
  type        = string
  default     = ""
}

variable "log_analytics_name" {
  description = "Optional override for the Log Analytics workspace name."
  type        = string
  default     = ""
}

variable "firewall_name" {
  description = "Optional override for the Azure Firewall name."
  type        = string
  default     = ""
}

variable "route_table_name" {
  description = "Optional override for the route table name."
  type        = string
  default     = ""
}

variable "adf_name" {
  description = "Optional override for the Azure Data Factory name."
  type        = string
  default     = ""
}

variable "hub_address_space" {
  description = "Address space for the hub virtual network."
  type        = list(string)
  default     = ["10.42.0.0/24"]
}

variable "spoke_address_space" {
  description = "Address space for the spoke virtual network."
  type        = list(string)
  default     = ["10.42.1.0/22"]
}

variable "firewall_subnet_prefixes" {
  description = "Address prefixes for AzureFirewallSubnet in the hub VNet."
  type        = list(string)
  default     = ["10.42.0.0/24"]
}

variable "app_subnet_prefixes" {
  description = "Address prefixes for the application subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.42.1.0/24"]
}

variable "private_endpoint_subnet_prefixes" {
  description = "Address prefixes for the private endpoint subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.42.2.0/24"]
}

variable "databricks_public_subnet_prefixes" {
  description = "Address prefixes for the Databricks public subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.42.3.0/24"]
}

variable "databricks_private_subnet_prefixes" {
  description = "Address prefixes for the Databricks private subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.42.4.0/24"]
}

variable "aks_subnet_prefixes" {
  description = "Address prefixes for the AKS subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.42.5.0/24"]
}

variable "jumpbox_subnet_prefixes" {
  description = "Address prefixes for the jumpbox subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.42.6.0/24"]
}

variable "sqlmi_subnet_prefixes" {
  description = "Address prefixes for the SQL Managed Instance subnet in the spoke VNet."
  type        = list(string)
  default     = ["10.42.7.0/24"]
}

variable "private_dns_zone_names" {
  description = "Private DNS zones created and linked to both hub and spoke VNets."
  type        = list(string)
  default = [
    "privatelink.blob.core.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azurewebsites.net",
    "privatelink.servicebus.windows.net",
    "privatelink.cognitiveservices.azure.com",
    "privatelink.datafactory.azure.net",
    "privatelink.database.windows.net"
  ]
}

variable "firewall_sku_tier" {
  description = "Azure Firewall SKU tier."
  type        = string
  default     = "Standard"
}

variable "log_analytics_retention_in_days" {
  description = "Retention period in days for the Log Analytics workspace."
  type        = number
  default     = 30
}

variable "log_analytics_internet_ingestion_enabled" {
  description = "Whether public ingestion is enabled for the Log Analytics workspace."
  type        = bool
  default     = true
}

variable "log_analytics_internet_query_enabled" {
  description = "Whether public query is enabled for the Log Analytics workspace."
  type        = bool
  default     = true
}

variable "log_analytics_local_authentication_disabled" {
  description = "Whether local authentication is disabled for the Log Analytics workspace."
  type        = bool
  default     = false
}

variable "log_analytics_reservation_capacity_in_gb_per_day" {
  description = "Optional commitment tier in GB/day for the Log Analytics workspace."
  type        = number
  default     = null
}

variable "app_admin_group" {
  description = "Optional Entra groups or object IDs with Contributor-style access on landing zone resources."
  type        = list(string)
  default     = []
}

variable "app_user_group" {
  description = "Optional Entra groups or object IDs with Reader-style access on landing zone resources."
  type        = list(string)
  default     = []
}

variable "jumpbox_public_network_enabled" {
  description = "Whether the example jumpbox VMs receive public IPs."
  type        = bool
  default     = true
}

variable "jumpbox_windows_image_publisher" {
  description = "Marketplace image publisher passed to the winvm module for the example jumpbox."
  type        = string
  default     = "MicrosoftWindowsServer"
}

variable "jumpbox_windows_image_offer" {
  description = "Marketplace image offer passed to the winvm module for the example jumpbox."
  type        = string
  default     = "WindowsServer"
}

variable "jumpbox_windows_image_sku" {
  description = "Marketplace image SKU passed to the winvm module for the example jumpbox."
  type        = string
  default     = "2022-Datacenter"
}

variable "jumpbox_windows_image_version" {
  description = "Marketplace image version passed to the winvm module for the example jumpbox."
  type        = string
  default     = "latest"
}

variable "sql_admin_username" {
  description = "Administrator login used by the Azure SQL Database example."
  type        = string
  default     = "sqladminuser"
}

variable "sql_admin_password" {
  description = "Administrator password used by the Azure SQL Database example."
  type        = string
  default     = "ChangeMeSql12345!"
  sensitive   = true
}

variable "sql_ad_admin_login" {
  description = "Microsoft Entra administrator name used by the Azure SQL Database example."
  type        = string
  default     = "sql-admin-group"
}

variable "sql_ad_admin_object_id" {
  description = "Microsoft Entra administrator object ID used by the Azure SQL Database example."
  type        = string
  default     = "00000000-0000-0000-0000-000000000000"
}

variable "sqlmi_admin_username" {
  description = "Administrator login used by the SQL Managed Instance example."
  type        = string
  default     = "sqlmiadminuser"
}

variable "sqlmi_admin_password" {
  description = "Administrator password used by the SQL Managed Instance example."
  type        = string
  default     = "ChangeMeSqlMi12345!"
  sensitive   = true
}

variable "allowed_policy_locations" {
  description = "Allowed Azure regions used by the sample allowed locations policy."
  type        = list(string)
  default     = ["canadacentral", "canadaeast"]
}

variable "platform_role_assignments" {
  description = "Optional platform RBAC assignments for the landing zone."
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
    principal_id         = optional(string)
    principal_name       = optional(string)
    principal_type       = optional(string)
    condition            = optional(string)
    condition_version    = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags applied to all landing zone resources."
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Pattern   = "platform-landing-zone"
  }
}
