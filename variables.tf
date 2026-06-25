variable "module_plan_enabled" {
  description = "Per-module plan toggle map. Leave all values false for a parse-only harness, then turn on a module when you want to run a live plan for that specific module. The higher-level features map can also enable selected modules."
  type = object({
    acr                   = bool
    adf                   = bool
    aks                   = bool
    applicationgateway    = bool
    appregistration       = bool
    appservice            = bool
    appserviceplan        = bool
    automationaccount     = bool
    azure_ai_search       = bool
    azure_ai_service      = bool
    cosmosdb              = bool
    databricks            = bool
    enterpriseapplication = bool
    eventhub              = bool
    firewall              = bool
    fortigate             = bool
    functionapp           = bool
    keyvault              = bool
    linuxvm               = bool
    loganalytics          = bool
    logicapp              = bool
    managedidentity       = bool
    managementgroups      = bool
    nsg                   = bool
    openai                = bool
    policy                = bool
    private_dns           = bool
    rg                    = bool
    roleassignments       = bool
    route_table           = bool
    servicebus            = bool
    sqldb                 = bool
    sqlmi                 = bool
    sqlmi_db              = bool
    storageaccount        = bool
    subscription_vending  = bool
    vnet                  = bool
    winvm                 = bool
  })
  default = {
    acr                   = false
    adf                   = false
    aks                   = false
    applicationgateway    = false
    appregistration       = false
    appservice            = false
    appserviceplan        = false
    automationaccount     = false
    azure_ai_search       = false
    azure_ai_service      = false
    cosmosdb              = false
    databricks            = false
    enterpriseapplication = false
    eventhub              = false
    firewall              = false
    fortigate             = false
    functionapp           = false
    keyvault              = false
    linuxvm               = false
    loganalytics          = false
    logicapp              = false
    managedidentity       = false
    managementgroups      = false
    nsg                   = false
    openai                = false
    policy                = false
    private_dns           = false
    rg                    = false
    roleassignments       = false
    route_table           = false
    servicebus            = false
    sqldb                 = false
    sqlmi                 = false
    sqlmi_db              = false
    storageaccount        = false
    subscription_vending  = false
    vnet                  = false
    winvm                 = false
  }
}

variable "features" {
  description = "Optional high-level feature switches migrated from landingzone. Known keys include enable_acr, enable_adf, enable_aks, enable_app_registration_for_appservice, enable_app_services, enable_application_gateway, enable_automation_accounts, enable_automation_ari_workloads, enable_azure_ai_search, enable_azure_ai_service, enable_cosmosdb, enable_databricks, enable_enterprise_application, enable_eventhub, enable_firewall, enable_fortigate, enable_functionapp, enable_keyvault, enable_linux_vm, enable_loganalytics, enable_logicapp, enable_managed_identity, enable_management_group, enable_nsg, enable_openai, enable_policy, enable_private_dns, enable_resource_group, enable_roleassignments, enable_route_table, enable_servicebus, enable_sqldb, enable_sqlmi, enable_sqlmi_db, enable_storageaccount, enable_subscription_bootstrap, enable_vnet, and enable_winvm. Unspecified keys fall back to module_plan_enabled."
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

# -------------------------------------------------------------------
# Root module pass-through inputs
# -------------------------------------------------------------------

variable "applicationgateway_name" {
  description = "Optional Application Gateway name override. Leave empty to derive agw-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "applicationgateway_subnet_id" {
  description = "Optional Application Gateway subnet resource ID override. Leave empty to use the app subnet ID."
  type        = string
  default     = ""
}

variable "applicationgateway_backend_address_pools" {
  description = "Application Gateway backend address pools."
  type        = any
  default = {
    app = {
      ip_addresses = ["10.42.1.4"]
    }
  }
}

variable "applicationgateway_backend_http_settings" {
  description = "Application Gateway backend HTTP settings."
  type        = any
  default = {
    app = {
      port     = 80
      protocol = "Http"
    }
  }
}

variable "applicationgateway_http_listeners" {
  description = "Application Gateway HTTP listeners."
  type        = any
  default = {
    public = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
  }
}

variable "applicationgateway_request_routing_rules" {
  description = "Application Gateway request routing rules."
  type        = any
  default = {
    public = {
      rule_type                  = "Basic"
      http_listener_name         = "public"
      backend_address_pool_name  = "app"
      backend_http_settings_name = "app"
      priority                   = 100
    }
  }
}

variable "cosmosdb_name" {
  description = "Optional Cosmos DB account name override. Leave empty to derive cosmos-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "cosmosdb_sql_databases" {
  description = "Cosmos DB SQL databases."
  type        = any
  default = {
    app = {
      autoscale_max_ru = 4000
    }
  }
}

variable "cosmosdb_sql_containers" {
  description = "Cosmos DB SQL containers."
  type        = any
  default = {
    items = {
      database_name       = "app"
      partition_key_paths = ["/tenantId"]
      autoscale_max_ru    = 4000
    }
  }
}

variable "databricks_name" {
  description = "Optional Databricks workspace name override. Leave empty to derive dbw-<workload>-<environment>."
  type        = string
  default     = ""
}

# -------------------------------------------------------------------
# enterpriseapplication
# -------------------------------------------------------------------

variable "enterprise_application_application_id" {
  description = "Application (client) ID of the app registration this Enterprise Application/service principal connects to. Leave empty to use the root appregistration module output when both modules are enabled."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.enterprise_application_application_id) == "" || can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.enterprise_application_application_id))
    error_message = "enterprise_application_application_id must be empty or an application/client ID GUID."
  }
}

variable "enterprise_application_account_enabled" {
  description = "Whether the Enterprise Application service principal account is enabled."
  type        = bool
  default     = true
}

variable "enterprise_application_app_role_assignment_required" {
  description = "Whether users or groups must be assigned an app role before signing in through the Enterprise Application."
  type        = bool
  default     = false
}

variable "enterprise_application_description" {
  description = "Optional description for the Enterprise Application."
  type        = string
  default     = null
}

variable "enterprise_application_notes" {
  description = "Optional notes for the Enterprise Application."
  type        = string
  default     = null
}

variable "enterprise_application_login_url" {
  description = "Optional URL Azure AD uses to launch the application from Microsoft 365 or My Apps."
  type        = string
  default     = null

  validation {
    condition     = var.enterprise_application_login_url == null || can(regex("^https?://", var.enterprise_application_login_url))
    error_message = "enterprise_application_login_url must be null or a valid http/https URL."
  }
}

variable "enterprise_application_preferred_single_sign_on_mode" {
  description = "Preferred single sign-on mode for the Enterprise Application. Use null to leave unset."
  type        = string
  default     = null

  validation {
    condition     = var.enterprise_application_preferred_single_sign_on_mode == null ? true : contains(["oidc", "password", "saml", "notSupported"], var.enterprise_application_preferred_single_sign_on_mode)
    error_message = "enterprise_application_preferred_single_sign_on_mode must be one of: oidc, password, saml, notSupported, or null."
  }
}

variable "enterprise_application_saml_relay_state" {
  description = "Optional SAML relay state. Applies only when preferred_single_sign_on_mode is saml."
  type        = string
  default     = null
}

variable "enterprise_application_owners" {
  description = "List of Entra object IDs to set as Enterprise Application owners."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.enterprise_application_owners :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))
    ])
    error_message = "enterprise_application_owners must contain only Microsoft Entra object IDs."
  }
}

variable "enterprise_application_add_current_caller_as_owner" {
  description = "When true, the current Terraform caller object ID is added as an owner."
  type        = bool
  default     = true
}

variable "enterprise_application_notification_email_addresses" {
  description = "Notification email addresses for the Enterprise Application."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for value in var.enterprise_application_notification_email_addresses :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", value))
    ])
    error_message = "enterprise_application_notification_email_addresses entries must be valid email addresses."
  }
}

variable "enterprise_application_feature_tags" {
  description = "Feature tags to classify the service principal as an Enterprise Application, gallery app, custom SSO app, or hidden app."
  type = object({
    custom_single_sign_on = optional(bool, false)
    enterprise            = optional(bool, true)
    gallery               = optional(bool, false)
    hide                  = optional(bool, false)
  })
  default = {
    enterprise = true
  }
}

variable "enterprise_application_use_existing" {
  description = "When true, the AzureAD provider attempts to use an existing service principal for application_id."
  type        = bool
  default     = true
}

variable "enterprise_application_app_role_assignments" {
  description = "App role assignments for users, groups, or service principals, keyed by logical name."
  type = map(object({
    principal_object_id = string
    app_role_id         = optional(string, "00000000-0000-0000-0000-000000000000")
  }))
  default = {}

  validation {
    condition = alltrue([
      for _, assignment in var.enterprise_application_app_role_assignments :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.principal_object_id)) &&
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.app_role_id))
    ])
    error_message = "enterprise_application_app_role_assignments entries must include principal_object_id and app_role_id GUIDs."
  }
}

variable "enterprise_application_create_application_proxy" {
  description = "When true, configures Microsoft Entra Application Proxy on the connected app registration."
  type        = bool
  default     = false
}

variable "enterprise_application_application_proxy" {
  description = "Application Proxy settings applied to the connected app registration when create_application_proxy is true."
  type = object({
    internal_url                                   = string
    external_url                                   = string
    external_authentication_type                   = optional(string, "aadPreAuthentication")
    application_server_timeout                     = optional(string, "Default")
    is_backend_certificate_validation_enabled      = optional(bool, true)
    is_http_only_cookie_enabled                    = optional(bool, true)
    is_persistent_cookie_enabled                   = optional(bool, false)
    is_secure_cookie_enabled                       = optional(bool, true)
    is_state_session_enabled                       = optional(bool, true)
    is_translate_host_header_enabled               = optional(bool, true)
    is_translate_links_in_body_enabled             = optional(bool, false)
    is_continuous_access_evaluation_enabled        = optional(bool, true)
    traffic_routing_method                         = optional(string, "none")
    use_alternate_url_for_translation_and_redirect = optional(bool, false)
    alternate_url                                  = optional(string)
    verified_custom_domain_key_credential          = optional(any)
    verified_custom_domain_password_credential     = optional(any)
    single_sign_on_settings                        = optional(any)
  })
  default = null

  validation {
    condition = var.enterprise_application_application_proxy == null ? true : (
      can(regex("^https?://", var.enterprise_application_application_proxy.internal_url)) &&
      can(regex("^https?://", var.enterprise_application_application_proxy.external_url)) &&
      contains(["passthru", "aadPreAuthentication"], var.enterprise_application_application_proxy.external_authentication_type) &&
      contains(["Default", "Long"], var.enterprise_application_application_proxy.application_server_timeout) &&
      contains(["none", "random", "sessionPersistence", "performance", "unknownFutureValue"], var.enterprise_application_application_proxy.traffic_routing_method)
    )
    error_message = "enterprise_application_application_proxy requires valid internal/external URLs, external_authentication_type, application_server_timeout, and traffic_routing_method values."
  }
}

variable "eventhub_name" {
  description = "Optional Event Hubs namespace name override. Leave empty to derive evh-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "eventhub_eventhubs" {
  description = "Event hubs to create in the namespace."
  type        = any
  default = {
    telemetry = {
      partition_count   = 2
      message_retention = 1
    }
  }
}

variable "firewall_name" {
  description = "Optional Azure Firewall name override. Leave empty to derive afw-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "firewall_subnet_id" {
  description = "Optional Azure Firewall subnet resource ID override. Leave empty to derive from network_resource_group_name, shared_vnet_name, and firewall_subnet_name."
  type        = string
  default     = ""
}

variable "fortigate_architecture" {
  description = "FortiGate architecture profile."
  type        = string
  default     = "single"
}

variable "fortigate_name_prefix" {
  description = "Optional FortiGate name prefix. Leave empty to derive fgt-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "fortigate_license_type" {
  description = "FortiGate licensing model."
  type        = string
  default     = "byol"
}

variable "fortigate_vm_size" {
  description = "Azure VM size for each FortiGate instance."
  type        = string
  default     = "Standard_F4s_v2"
}

variable "fortigate_availability_zones" {
  description = "Availability zone assigned to each active-passive FortiGate instance."
  type        = map(string)
  default = {
    a = "1"
    b = "2"
  }
}

variable "fortigate_single_zone" {
  description = "Optional zone for a single FortiGate VM."
  type        = string
  default     = ""
}

variable "fortigate_load_balancer_frontend_zones" {
  description = "Optional zones for FortiGate load balancer frontends and a created public IP."
  type        = list(string)
  default     = []
}

variable "fortigate_admin_username" {
  description = "FortiGate local administrator username."
  type        = string
  default     = "azureuser"
}

variable "fortigate_admin_password" {
  description = "Optional FortiGate administrator password."
  type        = string
  default     = ""
  sensitive   = true
}

variable "fortigate_admin_ssh_public_key" {
  description = "Optional SSH public key for FortiGate administration."
  type        = string
  default     = ""
  sensitive   = true
}

variable "fortigate_management_access_model" {
  description = "FortiGate operational management model."
  type        = string
  default     = "private"
}

variable "fortigate_image" {
  description = "FortiGate Marketplace image reference."
  type        = any
  default = {
    publisher = "fortinet"
    offer     = "fortinet_fortigate-vm_v5"
    sku       = "fortinet_fg-vm"
    version   = "latest"
  }
}

variable "fortigate_marketplace_plan" {
  description = "FortiGate Marketplace plan."
  type        = any
  default = {
    name      = "fortinet_fg-vm"
    product   = "fortinet_fortigate-vm_v5"
    publisher = "fortinet"
  }
}

variable "fortigate_os_disk" {
  description = "FortiGate OS disk settings."
  type        = any
  default     = {}
}

variable "fortigate_custom_data" {
  description = "Optional FortiOS bootstrap configuration."
  type        = string
  default     = ""
  sensitive   = true
}

variable "fortigate_create_subnets" {
  description = "Whether FortiGate creates its interface subnets in an existing VNet."
  type        = bool
  default     = false
}

variable "fortigate_virtual_network_name" {
  description = "Existing VNet name used when FortiGate creates subnets."
  type        = string
  default     = ""
}

variable "fortigate_virtual_network_resource_group_name" {
  description = "Resource group containing the FortiGate VNet."
  type        = string
  default     = ""
}

variable "fortigate_interfaces" {
  description = "FortiGate interface definitions."
  type        = any
  default = {
    external = {
      role      = "external"
      subnet_id = ""
      primary   = true
      private_ip_addresses = {
        a = "10.42.10.4"
        b = "10.42.10.5"
      }
    }
    internal = {
      role      = "internal"
      subnet_id = ""
      private_ip_addresses = {
        a = "10.42.11.4"
        b = "10.42.11.5"
      }
    }
  }
}

variable "fortigate_create_network_security_group" {
  description = "Whether FortiGate creates and associates an NSG."
  type        = bool
  default     = true
}

variable "fortigate_network_security_group_name" {
  description = "Optional FortiGate NSG name."
  type        = string
  default     = ""
}

variable "fortigate_network_security_rules" {
  description = "FortiGate NSG rules."
  type        = any
  default     = {}
}

variable "fortigate_internal_load_balancer" {
  description = "FortiGate internal load balancer settings."
  type        = any
  default     = {}
}

variable "fortigate_external_load_balancer" {
  description = "FortiGate external-side load balancer settings."
  type        = any
  default     = {}
}

variable "functionapp_name" {
  description = "Optional Function App name override. Leave empty to derive func-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "functionapp_service_plan_id" {
  description = "Optional Function App service plan ID override. Leave empty to use the appserviceplan module output or shared App Service Plan ID."
  type        = string
  default     = ""
}

variable "functionapp_storage_account_name" {
  description = "Optional Function App storage account name override. Leave empty to use the storageaccount module output or shared storage account name."
  type        = string
  default     = ""
}

variable "functionapp_storage_account_resource_group_name" {
  description = "Optional Function App storage account resource group override. Leave empty to use the storageaccount module output or shared resource group."
  type        = string
  default     = ""
}

variable "keyvault_name" {
  description = "Optional Key Vault name override for the keyvault module. Leave empty to use shared_key_vault_name or the derived shared Key Vault name."
  type        = string
  default     = ""
}

variable "loganalytics_name" {
  description = "Optional Log Analytics workspace name override. Leave empty to use shared_log_analytics_name or the derived shared workspace name."
  type        = string
  default     = ""
}

variable "logicapp_name" {
  description = "Optional Logic App name override. Leave empty to derive logic-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "logicapp_service_plan_id" {
  description = "Optional Logic App service plan ID override. Leave empty to use the appserviceplan module output or shared App Service Plan ID."
  type        = string
  default     = ""
}

variable "logicapp_storage_account_name" {
  description = "Optional Logic App storage account name override. Leave empty to use the storageaccount module output or shared storage account name."
  type        = string
  default     = ""
}

variable "logicapp_storage_account_resource_group_name" {
  description = "Optional Logic App storage account resource group override. Leave empty to use the storageaccount module output or shared resource group."
  type        = string
  default     = ""
}

variable "managedidentity_name" {
  description = "Optional managed identity name override. Leave empty to derive id-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "nsg_name" {
  description = "Optional NSG name override. Leave empty to derive nsg-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "nsg_security_rules" {
  description = "NSG security rules."
  type        = any
  default     = {}
}

variable "nsg_subnet_ids" {
  description = "Subnet IDs to associate with the NSG."
  type        = list(string)
  default     = []
}

variable "nsg_network_interface_ids" {
  description = "Network interface IDs to associate with the NSG."
  type        = list(string)
  default     = []
}

variable "policy_name" {
  description = "Optional policy definition name override. Leave empty to derive allowed-location-<environment>."
  type        = string
  default     = ""
}

variable "policy_display_name" {
  description = "Optional policy display name override. Leave empty to derive Allowed Location <ENV>."
  type        = string
  default     = ""
}

variable "policy_management_group_id" {
  description = "Optional policy management group ID override. Leave empty to use shared_management_group_name."
  type        = string
  default     = ""
}

variable "policy_rule" {
  description = "Policy rule JSON string. Leave empty to use the sample allowed-location audit rule."
  type        = string
  default     = ""
}

variable "rg_name" {
  description = "Optional resource group name override for the rg module. Leave empty to use shared_resource_group_name."
  type        = string
  default     = ""
}

variable "roleassignments_assignments" {
  description = "Role assignments passed to the roleassignments module. Leave empty to use the sample Reader assignment."
  type        = any
  default     = {}
}

variable "route_table_name" {
  description = "Optional route table name override. Leave empty to derive rt-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "route_table_routes" {
  description = "Route table routes."
  type        = any
  default     = {}
}

variable "route_table_subnet_ids" {
  description = "Subnet IDs to associate with the route table."
  type        = list(string)
  default     = []
}

variable "servicebus_name" {
  description = "Optional Service Bus namespace name override. Leave empty to derive sb-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "servicebus_queues" {
  description = "Service Bus queues."
  type        = any
  default     = {}
}

variable "servicebus_topics" {
  description = "Service Bus topics."
  type        = any
  default     = {}
}

variable "servicebus_subscriptions" {
  description = "Service Bus topic subscriptions."
  type        = any
  default     = {}
}

variable "sqlmi_name" {
  description = "Optional SQL Managed Instance name override. Leave empty to derive sqlmi-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "sqlmi_administrator_login" {
  description = "SQL Managed Instance administrator login."
  type        = string
  default     = "sqladminuser"
}

variable "sqlmi_administrator_login_password" {
  description = "SQL Managed Instance administrator password."
  type        = string
  default     = "ChangeMeSqlMi12345!"
  sensitive   = true
}

variable "sqlmi_sku_name" {
  description = "SQL Managed Instance SKU name."
  type        = string
  default     = "GP_Gen5"
}

variable "sqlmi_vcores" {
  description = "SQL Managed Instance vCore count."
  type        = number
  default     = 4
}

variable "sqlmi_storage_size_in_gb" {
  description = "SQL Managed Instance storage size in GB."
  type        = number
  default     = 64
}

variable "sqlmi_db_name" {
  description = "Optional SQL Managed Instance database name override. Leave empty to derive sqlmidb-<workload>-<environment>."
  type        = string
  default     = ""
}

variable "storageaccount_name" {
  description = "Optional storage account module name override. Leave empty to use shared_storage_account_name or the derived shared storage account name."
  type        = string
  default     = ""
}

variable "storageaccount_containers" {
  description = "Storage containers."
  type        = any
  default     = {}
}

variable "storageaccount_file_shares" {
  description = "Storage file shares."
  type        = any
  default     = {}
}

variable "storageaccount_queues" {
  description = "Storage queues."
  type        = any
  default     = {}
}

variable "storageaccount_tables" {
  description = "Storage tables."
  type        = any
  default     = {}
}

variable "vnet_name" {
  description = "Optional VNet name override. Leave empty to use shared_vnet_name."
  type        = string
  default     = ""
}

variable "vnet_address_space" {
  description = "VNet address space."
  type        = list(string)
  default     = ["10.42.0.0/16"]
}

variable "vnet_subnets" {
  description = "Optional VNet subnet map override. Leave empty to use the root harness sample subnets."
  type        = any
  default     = {}
}

variable "winvm_vm_remote_group" {
  description = "Optional Windows VM remote desktop group."
  type        = string
  default     = null
}

variable "winvm_vm_admin_group" {
  description = "Optional Windows VM administrators group."
  type        = string
  default     = null
}

variable "winvm_public_network_enabled" {
  description = "Whether public network access is enabled for the winvm module."
  type        = bool
  default     = false
}

variable "winvm_enable_shir" {
  description = "Whether to enable SHIR behavior for the winvm module."
  type        = bool
  default     = false
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
