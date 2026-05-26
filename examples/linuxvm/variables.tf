

# -------------------------------------------------------------------
# Shared Root Variables
# -------------------------------------------------------------------

variable "common_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "Dev"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
  }
}

variable "rg_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "Dev"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
    "Project Status"                    = "test"
    "workload"                          = "iactest"
    "IaC"                               = "Terraform"
    "Requested By"                      = "CCOE"
    "Provisioned By"                    = "admin@2join.us"
    "Technical contact"                 = "admin@2join.us"
    "Business contact"                  = "admin@2join.us"
    "ADO Project"                       = "CCoE-Infra-IaC"
    "ADO Repo"                          = "adf-lab"
    "ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/adf-lab"
  }
}

variable "location" {
  default     = "canadacentral"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "app_env" {
  type        = string
  description = "Environment, the environment name such as 'stg', 'prd', 'dev'"

  validation {
    condition     = var.app_env == null ? true : contains(["prod", "qa", "dev", "poc", "test", "sbx"], var.app_env)
    error_message = "app_env must be one of: prod, qa, dev, poc, test, sbx."
  }
}

variable "emachine-pub-key" {
  default = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIqfriZJbopqGHXo1gVfxo7LNF7rx+Yq1qSFpLeojDS4DWr/a8v2dpevDf95Xku/BGLZ16eRQFlW4/YFfhpPIy1sYVlaJQVOiALN8sk1R5OuGjLXy2e22SRVgH0LQehHCLwmszjuLhbmDO8qjNnzm0JIYHmv4+VkZ56LI8rTiPozHmKGxgKfhKhV1vh9NzdCnj7Nh/iQWAU82X5UzYU6J6t7Ape1bp4C74yPH3NOcVcV51qKZXiamfM2PfPnU11I+Wd7Ho8l1yvpUUZe0FdSBZtp7oWya+oPy5AXJlfuMCq5WjVUO9LCvpZMsJWQDhocMFuDRiNw4+0G/XnathEiRP root@emachine
EOT
}

variable "vm-pub-key" {
  default = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjoftGI4Wgwc6YHGgbbUfAkMm2k4JQIkMXmlHrs24bnSa+CxNeC4eL7cFWZHgLxn6pBfqRCijsCbLpzUhlIJKMMxv2WB0TtHpezD9oUX1/9K7rC3RB4EcKmZ3vDWSsR4UBn9aVCZkQBnr+hfk39lj+Hk2qAMGloVFD0bM10j1Hhv5uMaT8lcClWK/TCcgKH8NQF3hZDqX8YADCYczvZ7B3hA+xpAZwOOZKChOv5Y2ABduD8KPcV6Uc1VLO6+xMlkDZc0MB6HkYlGZSbeMkstgPo+275SKHWVJ7B2nWMvOAyOtjU5OqHwYoNrsCX1TP380DUhQqqAqjzqDP8C0z76Gj root@vm
EOT
}

variable "sku" {
  type        = string
  description = "The sku name of the Azure Cognitive Services server to create. Choose from: [F0 F1 S0 S S1 S2 S3 S4 S5 S6 P0 P1 P2 E0 DC0]"
  default     = "S0"
}

variable "iac_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
  default     = "rg-ccoe-iac-cc-nonprod"

}

variable "iac_kv" {
  type        = string
  description = "The name of the key vault in which the secrets will be stored."
  default     = "kv-ccoe-cc-nonprod"

}

variable "iac_st" {
  type        = string
  description = "The name of the storage account in which the Terraform state will be stored."
  default     = "stccoeiacccnonprod"

}

variable "workload" {
  type        = string
  description = "The name of the workload to be deployed."
  default     = "project"

  validation {
    condition     = can(regex("^[a-z0-9]{1,8}$", var.workload))
    error_message = "workload must be 1-8 lowercase alphanumeric characters to keep generated resource names valid."
  }
}

# -------------------------------------------------------------------
# End of Shared Root Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Azure Container Registry Module Variables
# -------------------------------------------------------------------

variable "acr_resource_group_name" {
  type        = string
  description = "The name of the resource group where the Azure Container Registry will be deployed."
  default     = "rg-ba-cc-prd-shared-management"
}

variable "acr_location" {
  type        = string
  description = "The Azure region where to deploy the Azure Container Registry."
  default     = "canadacentral"
}

variable "acr_name" {
  type        = string
  description = "Azure Container Registry name. Leave empty to auto-generate."
  default     = "acriactestprod001"
}

variable "acr_sku" {
  type        = string
  description = "Azure Container Registry SKU."
  default     = "Premium"
}

variable "acr_admin_enabled" {
  type        = bool
  description = "Whether the Azure Container Registry admin user is enabled."
  default     = false
}

variable "acr_public_network_access_enabled" {
  type        = bool
  description = "Whether the Azure Container Registry public endpoint is reachable."
  default     = false
}

variable "acr_anonymous_pull_enabled" {
  type        = bool
  description = "Whether anonymous pull access is enabled for the registry."
  default     = false
}

variable "acr_data_endpoint_enabled" {
  type        = bool
  description = "Whether dedicated data endpoints are enabled for the registry."
  default     = false
}

variable "acr_system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the registry."
  default     = false
}

variable "acr_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the registry."
  default     = []
}

variable "acr_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the registry."
  default     = []
}

variable "acr_enable_network_rule_set" {
  type        = bool
  description = "Whether to configure Premium SKU Azure Container Registry network rules."
  default     = false
}

variable "acr_network_rule_bypass_option" {
  type        = string
  description = "Bypass option for Azure Container Registry network rules."
  default     = "AzureServices"
}

variable "acr_network_rule_default_action" {
  type        = string
  description = "Default action for Azure Container Registry network rules."
  default     = "Deny"
}

variable "acr_network_rule_ip_rules" {
  type        = list(string)
  description = "Allowed public IP addresses or CIDR ranges for Azure Container Registry network rules."
  default     = []
}

variable "acr_enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure Container Registry."
  default     = false
}

variable "acr_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the Azure Container Registry private endpoint."
  default     = ""
}

variable "acr_private_endpoint_subnet_name" {
  type        = string
  description = "Existing subnet name used for Azure Container Registry private endpoint lookup."
  default     = null
}

variable "acr_private_endpoint_vnet_name" {
  type        = string
  description = "Existing virtual network name used for Azure Container Registry private endpoint subnet lookup."
  default     = null
}

variable "acr_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for Azure Container Registry private endpoint subnet lookup."
  default     = null
}

variable "acr_private_dns_zone_id" {
  type        = string
  description = "Optional Private DNS zone ID to attach to the Azure Container Registry private endpoint."
  default     = ""
}

variable "acr_private_dns_zone_name" {
  type        = string
  description = "Optional existing Private DNS zone name used for Azure Container Registry private endpoint DNS lookup."
  default     = ""
}

variable "acr_private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the Azure Container Registry private DNS zone used for private endpoint lookup."
  default     = ""
}

variable "acr_enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the Azure Container Registry."
  default     = false
}

variable "acr_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by Azure Container Registry diagnostics. Leave empty to use data.azurerm_log_analytics_workspace.this.id."
  default     = ""
}

variable "acr_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable for the Azure Container Registry."
  default     = ["ContainerRegistryRepositoryEvents", "ContainerRegistryLoginEvents"]
}

variable "acr_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable for the Azure Container Registry."
  default     = ["AllMetrics"]
}

variable "acr_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Azure Container Registry."
  default     = {}
}

# -------------------------------------------------------------------
# End of Azure Container Registry Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Azure Data Factory Module Variables
# -------------------------------------------------------------------

variable "adf_tags" {
  type = map(any)
  default = {
    "resourceType" = "ADF"
  }
}

variable "vsts_configuration" {
  description = "Azure DevOps repo settings for ADF"
  type = object({
    account_name         = string # ADO organization name
    project_name         = string # ADO project
    repository_name      = string
    branch_name          = string
    root_folder          = string # e.g. "/"
    tenant_id            = string # your AAD tenant GUID
    collaboration_branch = optional(string)
  })
  default = {
    account_name    = ""
    project_name    = ""
    repository_name = ""
    branch_name     = ""
    root_folder     = "/"
    tenant_id       = ""
  }
}

variable "self_hosted_integration_runtime_enabled" {
  type        = bool
  description = "Self Hosted Integration runtime"
  default     = false
}

variable "adf_resource_group_name" {
  type        = string
  description = "Optional override for the ADF resource group. Leave empty to use app_rg."
  default     = ""
}

variable "adf_location" {
  type        = string
  description = "Optional override for the ADF location. Leave empty to use the effective app resource group location."
  default     = ""
}

variable "adf_name" {
  type        = string
  description = "Optional override for the ADF name. Leave empty to use the generated default."
  default     = ""
}

variable "adf_default_integration_runtime_name" {
  type        = string
  description = "Optional override for the default Azure integration runtime name."
  default     = ""
}

variable "adf_diagnostics_name" {
  type        = string
  description = "Optional override for the ADF diagnostic setting base name."
  default     = ""
}

variable "adf_shir_name" {
  type        = string
  description = "Optional override for the Self-Hosted Integration Runtime name."
  default     = ""
}

variable "adf_shir_vm_name" {
  type        = string
  description = "Optional override for the SHIR Windows VM name. Leave empty to use the generated default."
  default     = ""
}

variable "adf_app_admin_group" {
  type        = list(string)
  description = "Microsoft Entra groups granted Contributor on the Azure Data Factory resource."
  default     = []
}

variable "adf_app_user_group" {
  type        = list(string)
  description = "Microsoft Entra groups granted Reader on the Azure Data Factory resource and reused as remote-access groups for the SHIR VM path."
  default     = []
}

variable "adf_public_network_enabled" {
  type        = bool
  description = "Whether the Azure Data Factory public endpoint is enabled."
  default     = false
}

variable "adf_managed_virtual_network_enabled" {
  type        = bool
  description = "Whether managed virtual network is enabled for Azure Data Factory."
  default     = false
}

variable "adf_cleanup_enabled" {
  type        = bool
  description = "Whether the default Azure integration runtime cleanup is enabled."
  default     = true
}

variable "adf_compute_type" {
  type        = string
  description = "Compute type for the default Azure integration runtime."
  default     = "General"
}

variable "adf_core_count" {
  type        = number
  description = "Core count for the default Azure integration runtime."
  default     = 8
}

variable "adf_time_to_live_min" {
  type        = number
  description = "Time to live in minutes for the default Azure integration runtime."
  default     = 15
}

variable "adf_virtual_network_enabled" {
  type        = bool
  description = "Whether the default Azure integration runtime uses managed virtual network."
  default     = false
}

variable "adf_self_hosted_integration_runtime_enabled" {
  type        = bool
  description = "Whether to create a Self-Hosted Integration Runtime and SHIR VM path."
  default     = false
}

variable "adf_enable_private_endpoint" {
  type        = bool
  description = "Whether to create the ADF control-plane private endpoint."
  default     = false
}

variable "adf_private_dns_zone_id" {
  type        = string
  description = "Optional existing private DNS zone ID for privatelink.datafactory.azure.net."
  default     = ""
}

variable "adf_private_dns_zone_name" {
  type        = string
  description = "Private DNS zone name used when looking up the existing ADF private DNS zone."
  default     = "privatelink.datafactory.azure.net"
}

variable "adf_private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the existing ADF private DNS zone when adf_private_dns_zone_id is not provided."
  default     = ""
}

variable "adf_enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for Azure Data Factory."
  default     = false
}

variable "adf_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by ADF diagnostics. Leave empty to use data.azurerm_log_analytics_workspace.this.id."
  default     = ""
}

variable "adf_analytics_destination_type" {
  type        = string
  description = "ADF diagnostics destination type."
  default     = "Dedicated"
}

variable "adf_managed_private_endpoint" {
  description = "Managed private endpoints to create inside Azure Data Factory."
  type = set(object({
    name               = string
    target_resource_id = string
    subresource_name   = string
  }))
  default = []
}

variable "adf_global_parameter" {
  description = "Global parameters to create in Azure Data Factory."
  type = list(object({
    name  = string
    type  = optional(string, "String")
    value = string
  }))
  default = []
}

variable "adf_permissions" {
  description = "ADF RBAC assignments as object_id and role pairs."
  type        = list(map(string))
  default     = []
}

variable "adf_vsts_configuration" {
  description = "Azure DevOps repo settings for the ADF module."
  type = object({
    account_name         = string
    project_name         = string
    repository_name      = string
    branch_name          = string
    root_folder          = string
    tenant_id            = string
    collaboration_branch = optional(string)
  })
  default = {
    account_name    = ""
    project_name    = ""
    repository_name = ""
    branch_name     = ""
    root_folder     = "/"
    tenant_id       = ""
  }
}

# -------------------------------------------------------------------
# End of Azure Data Factory Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# AKS Module Variables
# -------------------------------------------------------------------

variable "aks_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the AKS cluster will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "aks_location" {
  type        = string
  description = "Optional override for the Azure region where to deploy AKS. Leave empty to use the resource group location."
  default     = ""
}

variable "aks_name" {
  type        = string
  description = "Optional override for the AKS cluster name."
  default     = ""
}

variable "aks_dns_prefix" {
  type        = string
  description = "Optional override for the AKS DNS prefix."
  default     = ""
}

variable "aks_kubernetes_version" {
  type        = string
  description = "Optional Kubernetes version for AKS."
  default     = null
}

variable "aks_sku_tier" {
  type        = string
  description = "AKS SKU tier."
  default     = "Free"
}

variable "aks_automatic_upgrade_channel" {
  type        = string
  description = "AKS automatic upgrade channel."
  default     = "patch"
}

variable "aks_private_cluster_enabled" {
  type        = bool
  description = "Whether the AKS API server is private."
  default     = true
}

variable "aks_private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone resource ID for AKS."
  default     = ""
}

variable "aks_private_dns_zone_name" {
  type        = string
  description = "Optional private DNS zone name for AKS lookup."
  default     = ""
}

variable "aks_private_dns_zone_resource_group_name" {
  type        = string
  description = "Optional resource group containing aks_private_dns_zone_name."
  default     = ""
}

variable "aks_role_based_access_control_enabled" {
  type        = bool
  description = "Whether Kubernetes RBAC is enabled."
  default     = true
}

variable "aks_azure_rbac_enabled" {
  type        = bool
  description = "Whether Azure RBAC for Kubernetes Authorization is enabled."
  default     = true
}

variable "aks_local_account_disabled" {
  type        = bool
  description = "Whether local AKS admin accounts are disabled."
  default     = true
}

variable "aks_oidc_issuer_enabled" {
  type        = bool
  description = "Whether the AKS OIDC issuer is enabled."
  default     = true
}

variable "aks_workload_identity_enabled" {
  type        = bool
  description = "Whether AKS Workload Identity is enabled."
  default     = true
}

variable "aks_app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive AKS admin access."
  default     = []
}

variable "aks_app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access on the AKS cluster resource."
  default     = []
}

variable "aks_default_node_pool" {
  description = "AKS default node pool configuration."
  type = object({
    name                         = optional(string, "system")
    vm_size                      = optional(string, "Standard_D4s_v5")
    node_count                   = optional(number, 1)
    enable_auto_scaling          = optional(bool, false)
    min_count                    = optional(number)
    max_count                    = optional(number)
    zones                        = optional(list(string), [])
    os_disk_size_gb              = optional(number, 128)
    max_pods                     = optional(number)
    vnet_subnet_id               = optional(string)
    only_critical_addons_enabled = optional(bool, false)
    orchestrator_version         = optional(string)
    os_sku                       = optional(string, "Ubuntu")
    type                         = optional(string, "VirtualMachineScaleSets")
  })
  default = {}
}

variable "aks_network_profile" {
  description = "AKS network profile configuration."
  type = object({
    network_plugin      = optional(string, "azure")
    network_plugin_mode = optional(string)
    network_policy      = optional(string)
    service_cidr        = optional(string)
    dns_service_ip      = optional(string)
    load_balancer_sku   = optional(string, "standard")
    outbound_type       = optional(string, "loadBalancer")
  })
  default = {}
}

variable "aks_enable_diagnostics" {
  type        = bool
  description = "Whether to enable diagnostics for AKS."
  default     = false
}

variable "aks_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by AKS diagnostics. Leave empty to use data.azurerm_log_analytics_workspace.this.id."
  default     = ""
}

variable "aks_diagnostic_log_categories" {
  type        = list(string)
  description = "AKS diagnostic log categories to enable."
  default     = []
}

variable "aks_diagnostic_metric_categories" {
  type        = list(string)
  description = "AKS diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "aks_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AKS cluster."
  default     = {}
}

# -------------------------------------------------------------------
# End of AKS Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# App Registration Module Variables
# -------------------------------------------------------------------

variable "app_registration_display_name" {
  description = "Optional display name override for the Entra app registration used by App Service."
  type        = string
  default     = null
}

variable "app_registration_web_redirect_uris" {
  description = "Optional redirect URIs for the Entra app registration. If empty and app registration is enabled, a default App Service callback URI is used."
  type        = list(string)
  default     = []
}

variable "app_registration_create_client_secret" {
  description = "When true, create a client secret for the Entra app registration."
  type        = bool
  default     = false
}

# -------------------------------------------------------------------
# End of App Registration Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# App Service Module Variables
# -------------------------------------------------------------------

variable "enable_app_registration_for_appservice" {
  description = "When true, create an Entra app registration and wire it to App Service authentication."
  type        = bool
  default     = false
}

variable "app_service_auth_mode" {
  description = "Authentication mode for App Service integration. Allowed: none, easy_auth, msal, both."
  type        = string
  default     = "msal"

  validation {
    condition     = contains(["none", "easy_auth", "msal", "both"], var.app_service_auth_mode)
    error_message = "app_service_auth_mode must be one of: none, easy_auth, msal, both."
  }
}

variable "app_service_allow_anonymous" {
  description = "When true and Easy Auth is active, unauthenticated requests are allowed."
  type        = bool
  default     = true
}

variable "app_service_unauthenticated_action" {
  description = "Optional override for Easy Auth unauthenticated action: RedirectToLoginPage, AllowAnonymous, Return401, Return403."
  type        = string
  default     = null

  validation {
    condition = var.app_service_unauthenticated_action == null || contains([
      "RedirectToLoginPage",
      "AllowAnonymous",
      "Return401",
      "Return403"
    ], var.app_service_unauthenticated_action)
    error_message = "app_service_unauthenticated_action must be null or one of: RedirectToLoginPage, AllowAnonymous, Return401, Return403."
  }
}

variable "appservice_stack" {
  description = "Application stack for App Service. Allowed values: dotnet, python, node."
  type        = string
  default     = "python"

  validation {
    condition     = contains(["dotnet", "python", "node"], lower(var.appservice_stack))
    error_message = "appservice_stack must be one of: dotnet, python, node."
  }
}

variable "app_service_app_settings" {
  description = "Additional App Service application settings to merge into the default settings."
  type        = map(string)
  default     = {}
}

variable "appservice_deployment_center_use_manual_integration" {
  description = "Whether App Service Deployment Center should use manual integration (true) or continuous integration (false)."
  type        = bool
  default     = true
}

variable "appservice_application_stack" {
  description = "Optional App Service runtime/container stack settings. Set to null to avoid pinning runtime versions in Terraform."
  type = object({
    docker_image_name        = optional(string)
    docker_registry_url      = optional(string)
    docker_registry_username = optional(string)
    docker_registry_password = optional(string)
    dotnet_version           = optional(string)
    node_version             = optional(string)
    python_version           = optional(string)
    php_version              = optional(string)
    java_version             = optional(string)
    current_stack            = optional(string)
  })
  default = null
}

variable "app_service_app_admin_group" {
  description = "Microsoft Entra groups granted Contributor on the App Service resource."
  type        = list(string)
  default     = []
}

variable "app_service_app_user_group" {
  description = "Microsoft Entra groups granted Reader on the App Service resource."
  type        = list(string)
  default     = []
}

variable "app_service_private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID used by the App Service private endpoint."
  default     = ""
}

variable "app_service_private_dns_zone_name" {
  type        = string
  description = "Existing private DNS zone name used for App Service private endpoint DNS lookup."
  default     = ""
}

variable "app_service_private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the private DNS zone used for App Service private endpoint DNS lookup."
  default     = ""
}

# -------------------------------------------------------------------
# End of App Service Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# App Service Plan Module Variables
# -------------------------------------------------------------------

variable "function_app_service_plan_sku_name" {
  type        = string
  description = "SKU name for the App Service Plan used by the Function App."
  default     = "B1"
}

variable "function_app_service_plan_name" {
  type        = string
  description = "Optional override for the App Service Plan name used by the Function App. Leave empty to use the root app_service_plan module output."
  default     = ""
}

variable "function_app_service_plan_resource_group_name" {
  type        = string
  description = "Optional override for the resource group containing the App Service Plan used by the Function App. Leave empty to use the root app_service_plan module output."
  default     = ""
}

variable "function_app_service_plan_app_admin_group" {
  type        = list(string)
  description = "Microsoft Entra groups granted Contributor on the App Service Plan used by the Function App."
  default     = []
}

variable "function_app_service_plan_app_user_group" {
  type        = list(string)
  description = "Microsoft Entra groups granted Reader on the App Service Plan used by the Function App."
  default     = []
}

# -------------------------------------------------------------------
# End of App Service Plan Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Automation Account Module Variables
# -------------------------------------------------------------------

variable "ari_container_name" {
  description = "Blob container name used by Automation Account runbook output and scoped RBAC assignment."
  type        = string
  default     = "ari"
}

variable "ari_report_name" {
  description = "Report name used by the Automation Account runbook output."
  type        = string
  default     = "2JOINUS_AZURE"
}

variable "automation_account_public_access_enabled" {
  description = "Whether the Automation Account remains publicly accessible. Set this to false when enabling the Hybrid Worker private endpoint."
  type        = bool
  default     = true
}

variable "enable_webhook_private_endpoint" {
  description = "Create the Automation Account Webhook private endpoint."
  type        = bool
  default     = false
}

variable "enable_hrw_private_endpoint" {
  description = "Create the Automation Account DscAndHybridWorker private endpoint. Requires automation_account_public_access_enabled = false."
  type        = bool
  default     = false
}

variable "automation_account_app_admin_group" {
  description = "Microsoft Entra groups granted Contributor on the Automation Account."
  type        = list(string)
  default     = []
}

variable "automation_account_app_user_group" {
  description = "Microsoft Entra groups granted Reader on the Automation Account."
  type        = list(string)
  default     = []
}

variable "ari_schedule_start_time" {
  description = "Optional RFC3339 start time for the ARI Automation schedule. Leave null to default to 24 hours from apply time."
  type        = string
  default     = null

  validation {
    condition     = var.ari_schedule_start_time == null ? true : can(formatdate("", var.ari_schedule_start_time))
    error_message = "ari_schedule_start_time must be a valid RFC3339 timestamp when provided."
  }
}

variable "hybrid_worker_vm_name" {
  description = "Existing Windows VM name that will host the Hybrid Runbook Worker extension."
  type        = string
  default     = "azuwiccoejmp001"
}

variable "hybrid_worker_vm_resource_group" {
  description = "Resource group of the existing Windows VM used for Hybrid Runbook Worker."
  type        = string
  default     = "rg-ba-cc-prd-shared-management"
}

variable "hybrid_worker_extension_name" {
  description = "Name of the VM extension resource for Hybrid Runbook Worker."
  type        = string
  default     = "HybridWorkerExtension"
}

variable "hybrid_worker_extension_type_handler_version" {
  description = "Hybrid Runbook Worker VM extension type handler version."
  type        = string
  default     = "1.1"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+$", var.hybrid_worker_extension_type_handler_version))
    error_message = "hybrid_worker_extension_type_handler_version must look like '1.1'."
  }
}

# -------------------------------------------------------------------
# End of Automation Account Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Azure AI Service Module Variables
# -------------------------------------------------------------------

variable "azure_ai_service_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the Azure AI Services account will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "azure_ai_service_location" {
  type        = string
  description = "Optional override for the Azure region where the Azure AI Services account will be deployed. Leave empty to use app_rg location."
  default     = ""
}

variable "azure_ai_service_name" {
  type        = string
  description = "Azure AI Services account name. Leave empty to auto-generate an account name."
  default     = ""
}

variable "azure_ai_service_sku_name" {
  type        = string
  description = "SKU name for the Azure AI Services account."
  default     = "S0"
}

variable "azure_ai_service_custom_subdomain_name" {
  type        = string
  description = "Optional custom subdomain name for the Azure AI Services account."
  default     = ""
}

variable "azure_ai_service_public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = true
}

variable "azure_ai_service_outbound_network_access_restricted" {
  type        = bool
  description = "Whether outbound network access is restricted."
  default     = false
}

variable "azure_ai_service_local_auth_enabled" {
  type        = bool
  description = "Whether local authentication keys are enabled."
  default     = true
}

variable "azure_ai_service_dynamic_throttling_enabled" {
  type        = bool
  description = "Whether dynamic throttling is enabled."
  default     = false
}

variable "azure_ai_service_fqdns" {
  type        = list(string)
  description = "Optional list of outbound FQDNs."
  default     = []
}

variable "azure_ai_service_project_management_enabled" {
  type        = bool
  description = "Whether project management is enabled."
  default     = false
}

variable "azure_ai_service_identity" {
  description = "Optional managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null
}

variable "azure_ai_service_customer_managed_key" {
  description = "Optional customer-managed key configuration."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null
}

variable "azure_ai_service_storage" {
  description = "Optional storage account attachment for Azure AI Services."
  type = list(object({
    storage_account_id = string
    identity_client_id = optional(string)
  }))
  default = []
}

variable "azure_ai_service_network_acls" {
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

variable "azure_ai_service_enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure AI Services account."
  default     = false
}

variable "azure_ai_service_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""
}

variable "azure_ai_service_private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "azure_ai_service_private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve the private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "azure_ai_service_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the private endpoint subnet."
  default     = ""
}

variable "azure_ai_service_private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone ID to attach to the private endpoint."
  default     = ""
}

variable "azure_ai_service_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Azure AI Services account."
  default     = []
}

variable "azure_ai_service_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Azure AI Services account."
  default     = []
}

variable "azure_ai_service_enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure AI Services account."
  default     = false
}

variable "azure_ai_service_log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID used when Azure AI Services diagnostics are enabled."
  default     = ""
}

variable "azure_ai_service_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable on the Azure AI Services account."
  default     = []
}

variable "azure_ai_service_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable on the Azure AI Services account."
  default     = ["AllMetrics"]
}

variable "azure_ai_service_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Azure AI Services account."
  default     = {}
}

# -------------------------------------------------------------------
# End of Azure AI Service Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Databricks Module Variables
# -------------------------------------------------------------------

variable "databricks_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the Databricks workspace will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "databricks_location" {
  type        = string
  description = "Optional override for the Azure region where the Databricks workspace will be deployed. Leave empty to use app_rg location."
  default     = ""
}

variable "databricks_name" {
  type        = string
  description = "Databricks workspace name. Leave empty to auto-generate a workspace name."
  default     = ""
}

variable "databricks_sku" {
  type        = string
  description = "Databricks workspace SKU."
  default     = "premium"
}

variable "databricks_managed_resource_group_name" {
  type        = string
  description = "Optional managed resource group name for the Databricks workspace."
  default     = ""
}

variable "databricks_public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled on the Databricks workspace."
  default     = true
}

variable "databricks_network_security_group_rules_required" {
  type        = string
  description = "Network security group rules mode for VNet-injected workspaces."
  default     = "AllRules"
}

variable "databricks_customer_managed_key_enabled" {
  type        = bool
  description = "Whether customer-managed keys are enabled."
  default     = false
}

variable "databricks_infrastructure_encryption_enabled" {
  type        = bool
  description = "Whether infrastructure encryption is enabled."
  default     = false
}

variable "databricks_default_storage_firewall_enabled" {
  type        = bool
  description = "Whether the default storage account firewall is enabled."
  default     = false
}

variable "databricks_access_connector_id" {
  type        = string
  description = "Optional Databricks access connector resource ID."
  default     = ""
}

variable "databricks_load_balancer_backend_address_pool_id" {
  type        = string
  description = "Optional load balancer backend address pool ID for secure cluster connectivity."
  default     = ""
}

variable "databricks_managed_disk_cmk_key_vault_id" {
  type        = string
  description = "Optional Key Vault ID for managed disk CMK."
  default     = ""
}

variable "databricks_managed_disk_cmk_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key ID for managed disk CMK."
  default     = ""
}

variable "databricks_managed_disk_cmk_rotation_to_latest_version_enabled" {
  type        = bool
  description = "Whether managed disk CMK should auto-rotate to the latest key version."
  default     = false
}

variable "databricks_managed_services_cmk_key_vault_id" {
  type        = string
  description = "Optional Key Vault ID for managed services CMK."
  default     = ""
}

variable "databricks_managed_services_cmk_key_vault_key_id" {
  type        = string
  description = "Optional Key Vault key ID for managed services CMK."
  default     = ""
}

variable "databricks_custom_parameters" {
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
}

variable "databricks_enhanced_security_compliance" {
  description = "Optional enhanced security and compliance settings for the Databricks workspace."
  type = object({
    automatic_cluster_update_enabled      = optional(bool)
    compliance_security_profile_enabled   = optional(bool)
    compliance_security_profile_standards = optional(set(string))
    enhanced_security_monitoring_enabled  = optional(bool)
  })
  default = null
}

variable "databricks_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Databricks workspace."
  default     = []
}

variable "databricks_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Databricks workspace."
  default     = []
}

variable "databricks_enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Databricks workspace."
  default     = false
}

variable "databricks_log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID used when Databricks diagnostics are enabled."
  default     = ""
}

variable "databricks_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable on the Databricks workspace."
  default     = []
}

variable "databricks_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable on the Databricks workspace."
  default     = ["AllMetrics"]
}

variable "databricks_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Databricks workspace."
  default     = {}
}

# -------------------------------------------------------------------
# End of Databricks Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Event Hub Module Variables
# -------------------------------------------------------------------

variable "eventhub_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the Event Hub namespace will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "eventhub_location" {
  type        = string
  description = "Optional override for the Azure region where the Event Hub namespace will be deployed. Leave empty to use app_rg location."
  default     = ""
}

variable "eventhub_name" {
  type        = string
  description = "Event Hub namespace name. Leave empty to auto-generate a namespace name."
  default     = ""
}

variable "eventhub_sku" {
  type        = string
  description = "Event Hub namespace SKU."
  default     = "Standard"
}

variable "eventhub_capacity" {
  type        = number
  description = "Event Hub namespace capacity."
  default     = 1
}

variable "eventhub_auto_inflate_enabled" {
  type        = bool
  description = "Whether auto-inflate is enabled for the Event Hub namespace."
  default     = false
}

variable "eventhub_maximum_throughput_units" {
  type        = number
  description = "Maximum throughput units when auto-inflate is enabled."
  default     = 0
}

variable "eventhub_local_authentication_enabled" {
  type        = bool
  description = "Whether SAS/local authentication is enabled for the Event Hub namespace."
  default     = true
}

variable "eventhub_public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for the Event Hub namespace."
  default     = true
}

variable "eventhub_minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the Event Hub namespace."
  default     = "1.2"
}

variable "eventhub_system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the Event Hub namespace."
  default     = false
}

variable "eventhub_eventhubs" {
  type = map(object({
    partition_count   = optional(number, 2)
    message_retention = optional(number, 1)
    status            = optional(string, "Active")
  }))
  description = "Map of Event Hubs keyed by Event Hub name."
  default     = {}
}

variable "eventhub_authorization_rules" {
  type = map(object({
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  description = "Optional namespace authorization rules keyed by rule name."
  default     = {}
}

variable "eventhub_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Event Hub namespace."
  default     = []
}

variable "eventhub_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Event Hub namespace."
  default     = []
}

variable "eventhub_enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Event Hub namespace."
  default     = false
}

variable "eventhub_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the Event Hub private endpoint."
  default     = ""
}

variable "eventhub_private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the Event Hub private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "eventhub_private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve the Event Hub private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "eventhub_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the Event Hub private endpoint subnet."
  default     = ""
}

variable "eventhub_private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone ID to attach to the Event Hub private endpoint."
  default     = ""
}

variable "eventhub_enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Event Hub namespace."
  default     = false
}

variable "eventhub_log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID used when Event Hub diagnostics are enabled."
  default     = ""
}

variable "eventhub_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable on the Event Hub namespace."
  default     = ["ArchiveLogs", "OperationalLogs"]
}

variable "eventhub_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable on the Event Hub namespace."
  default     = ["AllMetrics"]
}

variable "eventhub_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Event Hub namespace."
  default     = {}
}

# -------------------------------------------------------------------
# End of Event Hub Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Firewall Module Variables
# -------------------------------------------------------------------

variable "firewall_name" {
  type        = string
  description = "Azure Firewall name."
  default     = "afw-iactest-prod-001"
}

variable "firewall_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where Azure Firewall will be deployed."
  default     = ""
}

variable "firewall_location" {
  type        = string
  description = "Optional override for the Azure region where Azure Firewall will be deployed."
  default     = ""
}

variable "firewall_subnet_id" {
  type        = string
  description = "Resource ID of AzureFirewallSubnet."
  default     = ""
}

variable "firewall_sku_tier" {
  type        = string
  description = "Azure Firewall SKU tier."
  default     = "Standard"
}

variable "firewall_sku_name" {
  type        = string
  description = "Azure Firewall SKU name."
  default     = "AZFW_VNet"
}

variable "firewall_zones" {
  type        = list(string)
  description = "Optional availability zones for Azure Firewall and its public IP."
  default     = []
}

variable "firewall_public_ip_name" {
  type        = string
  description = "Optional override for the Azure Firewall public IP name."
  default     = ""
}

variable "firewall_policy_name" {
  type        = string
  description = "Optional override for the Azure Firewall policy name."
  default     = ""
}

variable "firewall_application_rule_collections" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  description = "Azure Firewall application rule collections keyed by collection name."
  default     = {}
}

variable "firewall_network_rule_collections" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
      protocols             = list(string)
    }))
  }))
  description = "Azure Firewall network rule collections keyed by collection name."
  default     = {}
}

variable "firewall_nat_rule_collections" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses    = list(string)
      destination_address = string
      destination_ports   = list(string)
      translated_address  = string
      translated_port     = string
      protocols           = list(string)
    }))
  }))
  description = "Azure Firewall NAT rule collections keyed by collection name."
  default     = {}
}

variable "firewall_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to Azure Firewall resources."
  default     = {}
}

# -------------------------------------------------------------------
# End of Firewall Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Function App Module Variables
# -------------------------------------------------------------------

variable "function_app_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the Function App will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "function_app_location" {
  type        = string
  description = "Optional override for the Azure region where to deploy the Function App. Leave empty to use the resolved Function App resource group location."
  default     = ""
}

variable "function_app_name" {
  type        = string
  description = "Optional override for the Azure Function App name. Leave empty to use the default func-<workload>-<app_env>-<suffix> naming pattern."
  default     = ""
}

variable "function_app_os_type" {
  type        = string
  description = "Function App operating system."
  default     = "Linux"
}

variable "function_app_storage_account_name" {
  type        = string
  description = "Optional override for the storage account name used by the Function App. Leave empty to use the iac storage account."
  default     = ""
}

variable "function_app_storage_account_resource_group_name" {
  type        = string
  description = "Optional override for the resource group containing the storage account used by the Function App. Leave empty to use the iac resource group."
  default     = ""
}

variable "function_app_storage_uses_managed_identity" {
  type        = bool
  description = "Whether the Function App should use managed identity for storage."
  default     = false
}

variable "function_app_functions_extension_version" {
  type        = string
  description = "Functions runtime extension version."
  default     = "~4"
}

variable "function_app_builtin_logging_enabled" {
  type        = bool
  description = "Whether built-in platform logging is enabled."
  default     = false
}

variable "function_app_https_only" {
  type        = bool
  description = "Whether only HTTPS traffic is allowed."
  default     = true
}

variable "function_app_public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for the Function App."
  default     = false
}

variable "function_app_app_settings" {
  type        = map(string)
  description = "Additional application settings for the Function App."
  default     = {}
}

variable "function_app_app_admin_group" {
  type        = list(string)
  description = "Microsoft Entra groups granted Contributor on the Function App resource."
  default     = []
}

variable "function_app_app_user_group" {
  type        = list(string)
  description = "Microsoft Entra groups granted Reader on the Function App resource."
  default     = []
}

variable "function_app_connection_strings" {
  description = "Optional Function App connection strings."
  type = list(object({
    name  = string
    value = string
    type  = optional(string, "Custom")
  }))
  default = []
}

variable "function_app_application_stack" {
  description = "Function App runtime stack settings."
  type = object({
    dotnet_version              = optional(string)
    java_version                = optional(string)
    node_version                = optional(string)
    powershell_core_version     = optional(string)
    python_version              = optional(string)
    use_custom_runtime          = optional(bool)
    use_dotnet_isolated_runtime = optional(bool)
  })
  default = {
    python_version = "3.11"
  }

  validation {
    condition     = var.function_app_os_type == "Linux" || try(var.function_app_application_stack.python_version, null) == null
    error_message = "function_app_application_stack.python_version is supported only when function_app_os_type is Linux."
  }

  validation {
    condition = try(var.function_app_application_stack.dotnet_version, null) == null || (
      var.function_app_os_type == "Linux"
      ? can(regex("^\\d+\\.\\d+$", var.function_app_application_stack.dotnet_version))
      : can(regex("^v\\d+\\.\\d+$", var.function_app_application_stack.dotnet_version))
    )
    error_message = "function_app_application_stack.dotnet_version must use '8.0' format for Linux and 'v8.0' format for Windows."
  }

  validation {
    condition = length(compact([
      try(var.function_app_application_stack.dotnet_version, null),
      try(var.function_app_application_stack.java_version, null),
      try(var.function_app_application_stack.node_version, null),
      try(var.function_app_application_stack.powershell_core_version, null),
      try(var.function_app_application_stack.python_version, null),
      coalesce(try(var.function_app_application_stack.use_custom_runtime, null), false) ? "custom" : null
    ])) >= 1
    error_message = "function_app_application_stack must specify at least one runtime option."
  }

  validation {
    condition = length(compact([
      try(var.function_app_application_stack.dotnet_version, null),
      try(var.function_app_application_stack.java_version, null),
      try(var.function_app_application_stack.node_version, null),
      try(var.function_app_application_stack.powershell_core_version, null),
      try(var.function_app_application_stack.python_version, null),
      coalesce(try(var.function_app_application_stack.use_custom_runtime, null), false) ? "custom" : null
    ])) == 1
    error_message = "function_app_application_stack must define exactly one primary runtime option."
  }

  validation {
    condition     = !coalesce(try(var.function_app_application_stack.use_dotnet_isolated_runtime, null), false) || try(var.function_app_application_stack.dotnet_version, null) != null
    error_message = "function_app_application_stack.use_dotnet_isolated_runtime requires function_app_application_stack.dotnet_version."
  }
}

variable "function_app_system_assigned_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the Function App."
  default     = true
}

variable "function_app_identity_ids" {
  type        = list(string)
  description = "Optional user-assigned managed identity IDs for the Function App."
  default     = []
}

variable "function_app_key_vault_reference_identity_id" {
  type        = string
  description = "Managed identity ID used for Key Vault references in app settings."
  default     = null
}

variable "function_app_virtual_network_subnet_id" {
  type        = string
  description = "Subnet ID for Function App VNet integration."
  default     = ""
}

variable "function_app_vnet_integration_subnet_name" {
  type        = string
  description = "Existing subnet name used for Function App VNet integration lookup."
  default     = ""
}

variable "function_app_vnet_integration_vnet_name" {
  type        = string
  description = "Existing virtual network name used for Function App VNet integration subnet lookup."
  default     = ""
}

variable "function_app_vnet_integration_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for Function App VNet integration subnet lookup."
  default     = ""
}

variable "function_app_vnet_route_all_enabled" {
  type        = bool
  description = "Whether all outbound Function App traffic is routed through the VNet integration subnet."
  default     = false
}

variable "function_app_always_on" {
  type        = bool
  description = "Whether the Function App should remain warm."
  default     = true
}

variable "function_app_ftps_state" {
  type        = string
  description = "FTPS state for the Function App."
  default     = "Disabled"
}

variable "function_app_http2_enabled" {
  type        = bool
  description = "Whether HTTP/2 is enabled for the Function App."
  default     = true
}

variable "function_app_minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the Function App."
  default     = "1.2"
}

variable "function_app_use_32_bit_worker" {
  type        = bool
  description = "Whether the Function App should use a 32-bit worker process."
  default     = false
}

variable "function_app_health_check_path" {
  type        = string
  description = "Optional Function App health check path."
  default     = null
}

variable "function_app_health_check_eviction_time_in_min" {
  type        = number
  description = "Optional Function App health check eviction time in minutes."
  default     = null
}

variable "function_app_runtime_scale_monitoring_enabled" {
  type        = bool
  description = "Whether runtime scale monitoring is enabled."
  default     = false
}

variable "function_app_daily_memory_time_quota" {
  type        = number
  description = "Optional daily memory time quota for the Function App."
  default     = null
}

variable "function_app_zip_deploy_file" {
  type        = string
  description = "Optional local ZIP package path to deploy to the Function App."
  default     = null
}

variable "function_app_sticky_settings_app_setting_names" {
  type        = list(string)
  description = "App setting names that should remain sticky across Function App slot swaps."
  default     = []
}

variable "function_app_sticky_settings_connection_string_names" {
  type        = list(string)
  description = "Connection string names that should remain sticky across Function App slot swaps."
  default     = []
}

variable "function_app_enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Function App."
  default     = false
}

variable "function_app_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the Function App private endpoint."
  default     = ""
}

variable "function_app_private_endpoint_subnet_name" {
  type        = string
  description = "Existing subnet name used for Function App private endpoint lookup."
  default     = ""
}

variable "function_app_private_endpoint_vnet_name" {
  type        = string
  description = "Existing virtual network name used for Function App private endpoint subnet lookup."
  default     = ""
}

variable "function_app_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for Function App private endpoint subnet lookup."
  default     = ""
}

variable "function_app_private_dns_zone_id" {
  type        = string
  description = "Private DNS zone ID used by the Function App private endpoint."
  default     = ""
}

variable "function_app_private_dns_zone_name" {
  type        = string
  description = "Existing private DNS zone name used for Function App private endpoint DNS lookup."
  default     = ""
}

variable "function_app_private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the private DNS zone used for Function App private endpoint DNS lookup."
  default     = ""
}

variable "function_app_enable_diagnostics" {
  type        = bool
  description = "Whether to enable diagnostics for the Function App."
  default     = false
}

variable "function_app_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by Function App diagnostics. Leave empty to use data.azurerm_log_analytics_workspace.this.id."
  default     = ""
}

variable "function_app_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable for the Function App."
  default = [
    "AppServiceHTTPLogs",
    "AppServiceConsoleLogs",
    "AppServiceAppLogs",
    "AppServiceAuditLogs",
    "AppServiceIPSecAuditLogs",
    "AppServicePlatformLogs"
  ]
}

variable "function_app_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable for the Function App."
  default     = ["AllMetrics"]
}

variable "function_app_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Function App."
  default     = {}
}

# -------------------------------------------------------------------
# End of Function App Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Key Vault Module Variables
# -------------------------------------------------------------------

variable "key_vault_resource_group_name" {
  type        = string
  description = "The name of the resource group where the Key Vault will be deployed."
  default     = null
}

variable "key_vault_location" {
  type        = string
  description = "The Azure region where to deploy the Key Vault."
  default     = "canadacentral"
}

variable "key_vault_tenant_id" {
  type        = string
  description = "Tenant ID for the Key Vault. Leave empty to use the current caller tenant."
  default     = ""
}

variable "key_vault_name" {
  type        = string
  description = "Key Vault name."
  default     = "kviactestprod001"
}

variable "key_vault_sku_name" {
  type        = string
  description = "Key Vault SKU name."
  default     = "standard"
}

variable "key_vault_enable_rbac_authorization" {
  type        = bool
  description = "Whether Azure RBAC is used instead of access policies."
  default     = true
}

variable "key_vault_public_network_access_enabled" {
  type        = bool
  description = "Whether the Key Vault public endpoint is reachable."
  default     = false
}

variable "key_vault_purge_protection_enabled" {
  type        = bool
  description = "Whether purge protection is enabled."
  default     = false
}

variable "key_vault_soft_delete_retention_days" {
  type        = number
  description = "Soft delete retention in days."
  default     = 90
}

variable "key_vault_enabled_for_deployment" {
  type        = bool
  description = "Whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the vault."
  default     = false
}

variable "key_vault_enabled_for_disk_encryption" {
  type        = bool
  description = "Whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  default     = false
}

variable "key_vault_enabled_for_template_deployment" {
  type        = bool
  description = "Whether Azure Resource Manager is permitted to retrieve secrets from the vault."
  default     = false
}

variable "key_vault_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Key Vault Administrator access."
  default     = []
}

variable "key_vault_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Key Vault Secrets User access."
  default     = []
}

variable "key_vault_enable_network_acls" {
  type        = bool
  description = "Whether to configure Key Vault network ACLs."
  default     = false
}

variable "key_vault_network_acls_default_action" {
  type        = string
  description = "Default action for Key Vault network ACLs."
  default     = "Deny"
}

variable "key_vault_network_acls_bypass" {
  type        = string
  description = "Traffic classes to bypass the network ACLs."
  default     = "AzureServices"
}

variable "key_vault_network_acls_ip_rules" {
  type        = list(string)
  description = "IPv4 addresses or CIDR ranges allowed by Key Vault network ACLs."
  default     = []
}

variable "key_vault_network_acls_virtual_network_subnet_ids" {
  type        = list(string)
  description = "Subnet resource IDs allowed by Key Vault network ACLs."
  default     = []
}

variable "key_vault_enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Key Vault."
  default     = false
}

variable "key_vault_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the Key Vault private endpoint."
  default     = ""
}

variable "key_vault_private_endpoint_subnet_name" {
  type        = string
  description = "Existing subnet name used for Key Vault private endpoint lookup."
  default     = null
}

variable "key_vault_private_endpoint_vnet_name" {
  type        = string
  description = "Existing virtual network name used for Key Vault private endpoint subnet lookup."
  default     = null
}

variable "key_vault_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for Key Vault private endpoint subnet lookup."
  default     = null
}

variable "key_vault_private_dns_zone_id" {
  type        = string
  description = "Optional Private DNS zone ID to attach to the Key Vault private endpoint."
  default     = ""
}

variable "key_vault_private_dns_zone_name" {
  type        = string
  description = "Optional existing Private DNS zone name used for Key Vault private endpoint DNS lookup."
  default     = ""
}

variable "key_vault_private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the Key Vault private DNS zone used for private endpoint lookup."
  default     = ""
}

variable "key_vault_enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the Key Vault."
  default     = false
}

variable "key_vault_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by Key Vault diagnostics. Leave empty to use data.azurerm_log_analytics_workspace.this.id."
  default     = ""
}

variable "key_vault_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = ["AuditEvent"]
}

variable "key_vault_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "key_vault_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Key Vault."
  default     = {}
}

# -------------------------------------------------------------------
# End of Key Vault Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Linux VM Module Variables
# -------------------------------------------------------------------

variable "linux_vm_common_tags" {
  type        = map(any)
  description = "Common tags merged into all Linux VM module resources."
  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "Dev"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
  }
}

variable "linux_vm_rg_tags" {
  type        = map(any)
  description = "Module-specific tags merged with linux_vm_common_tags and applied to Linux VM module resources."
  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "Dev"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
    "Project Status"                    = "test"
    "workload"                          = "iactest"
    "IaC"                               = "Terraform"
    "Requested By"                      = "CCOE"
    "Provisioned By"                    = "admin@2join.us"
    "Technical contact"                 = "admin@2join.us"
    "Business contact"                  = "admin@2join.us"
    "ADO Project"                       = "CCoE-Infra-IaC"
    "ADO Repo"                          = "adf-lab"
    "ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/adf-lab"
  }
}

variable "linux_vm_location" {
  type        = string
  description = "The Azure region in which the Linux VM resources will be created."
  default     = "canadacentral"
}

variable "linux_vm_app_env" {
  type        = string
  description = "Environment, such as prod, qa, dev, poc, test, or sbx."
  default     = "prod"
}

variable "linux_vm_workload" {
  type        = string
  description = "Workload identifier used in Linux VM naming and tagging."
  default     = "iactest"
}

variable "linux_vm_azure_password" {
  type        = string
  description = "Optional root-level admin password override for the Linux VM module."
  default     = ""
  sensitive   = true
}

variable "linux_vm_post_init_script" {
  type        = string
  description = "Optional additional bash script content to run after the Linux VM module's built-in init.sh bootstrap completes."
  default     = ""
  sensitive   = true
}

variable "linux_vm_enable_entra_ssh_login" {
  type        = bool
  description = "Whether to enable Microsoft Entra ID SSH login on the Linux VMs."
  default     = false
}

variable "linux_vm_enable_linux_vm_extension" {
  type        = bool
  description = "Whether to enable the optional storage-backed localization CustomScript VM extension for Linux VMs."
  default     = false
}

variable "linux_vm_enable_system_assigned_identity" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the Linux VMs. Required when linux_vm_enable_linux_vm_extension = true."
  default     = true
}

variable "linux_vm_localization_container_name" {
  type        = string
  description = "Blob container name in the shared IaC storage account that holds Linux VM localization scripts."
  default     = "localization"
}

variable "linux_vm_localization_os_script_name" {
  type        = string
  description = "OS-level localization script blob name to download first when the optional Linux VM extension is enabled."
  default     = "ubuntu.sh"
}

variable "linux_vm_enable_domain_join" {
  type        = bool
  description = "Whether the Linux VM module should attempt domain join during bootstrap. Default is false, which skips the domain-join secret lookup and keeps the VM off domain."
  default     = false
}

variable "linux_vm_datadog_api_key" {
  type        = string
  description = "Legacy Datadog API key retained for Linux VM module compatibility."
  sensitive   = true
}

variable "linux_vm_disksize" {
  type        = number
  description = "Optional additional data disk size in GB. Set to 0 to skip the extra disk."
  default     = 100
}

variable "linux_vm_app_vm_number" {
  type        = number
  description = "Number of Linux VMs to create."
  default     = 1
}

variable "linux_vm_app_vm_size" {
  type        = string
  description = "Azure VM size for each Linux VM."
  default     = "Standard_D4s_v3"
}

variable "linux_vm_image_publisher" {
  type        = string
  description = "Publisher of the Linux VM image."
  default     = "Canonical"
}

variable "linux_vm_image_offer" {
  type        = string
  description = "Offer of the Linux VM image."
  default     = "ubuntu-24_04-lts"
}

variable "linux_vm_image_sku" {
  type        = string
  description = "SKU of the Linux VM image."
  default     = "server"
}

variable "linux_vm_image_version" {
  type        = string
  description = "Version of the Linux VM image."
  default     = "latest"
}

variable "linux_vm_iac_rg" {
  type        = string
  description = "Resource group containing the shared IaC storage account and Key Vault."
  default     = "rg-ccoe-iac-cc-prod"
}

variable "linux_vm_iac_kv" {
  type        = string
  description = "Shared Key Vault name containing Linux VM secrets."
  default     = "kv-ccoe-cc-prod"
}

variable "linux_vm_iac_st" {
  type        = string
  description = "Shared storage account name containing bootstrap scripts."
  default     = "stccoeiacprod"
}

variable "linux_vm_app_rg" {
  type        = string
  description = "Target resource group name for the Linux VM resources."
  default     = "rg-ba-cc-prd-shared-management"
}

variable "linux_vm_app_snet" {
  type        = string
  description = "Existing subnet name used for the Linux VM NICs."
  default     = "snet-ba-cc-prod-hub-sysmgmt"
}

variable "linux_vm_app_vnet_rg" {
  type        = string
  description = "Resource group containing the target virtual network."
  default     = "rg-ba-cc-prod-hub-network"
}

variable "linux_vm_app_vnet" {
  type        = string
  description = "Existing virtual network name used for the Linux VM NICs."
  default     = "vnet-ba-cc-prod-hub"
}

variable "linux_vm_app_vm" {
  type        = string
  description = "Base Linux VM name. Environment suffixes are appended by the module."
  default     = "azuwiccoejmp"
}

variable "linux_vm_domain" {
  type        = string
  description = "AD domain used by the Linux VM bootstrap script when linux_vm_enable_domain_join = true."
  default     = "2join.us"
}

variable "linux_vm_domain_join_user" {
  type        = string
  description = "Optional domain join user in domain\\username format, used only when linux_vm_enable_domain_join = true. Leave empty to use the domain-join-user Key Vault secret."
  default     = ""
}

variable "linux_vm_domain_join_username_secret_name" {
  type        = string
  description = "Key Vault secret name containing the Linux VM domain join username."
  default     = "domain-join-user"
}

variable "linux_vm_domain_join_ou" {
  type        = string
  description = "Legacy domain join OU value retained for Linux VM module compatibility. Only relevant when linux_vm_enable_domain_join = true."
  default     = "azure"
}

variable "linux_vm_app_user_group" {
  type        = list(string)
  description = "AD groups granted Reader on the VM resource and standard SSH access inside the Linux guest OS."
  default     = ["BA-G-CCOE-Admin-F", "BA-G-Azure-Owner-F", "2JOINUS-AzureDevOps-Admin"]
}

variable "linux_vm_app_admin_group" {
  type        = list(string)
  description = "AD groups granted Contributor on the VM resource and sudo/admin access inside the Linux guest OS."
  default     = ["BA-G-CCOE-Admin-F", "BA-G-Azure-Owner-F"]
}

variable "linux_vm_bastion_resource_name" {
  type        = string
  description = "Optional Bastion host name that receives Reader RBAC for linux_vm_app_admin_group and linux_vm_app_user_group."
  default     = "bas-net-cc-prd"
}

variable "linux_vm_bastion_resource_group_name" {
  type        = string
  description = "Resource group containing linux_vm_bastion_resource_name."
  default     = "rg-ba-cc-prod-hub-network"
}

variable "linux_vm_public_network_enabled" {
  type        = bool
  description = "Whether to create public IPs and NSGs for Linux VM SSH access."
  default     = false
}

# -------------------------------------------------------------------
# End of Linux VM Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Log Analytics Module Variables
# -------------------------------------------------------------------

variable "loganalytics_name" {
  type        = string
  description = "Log Analytics workspace name."
  default     = "law-iactest-prod-001"
}

variable "loganalytics_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the Log Analytics workspace will be deployed."
  default     = ""
}

variable "loganalytics_location" {
  type        = string
  description = "Optional override for the Azure region where the Log Analytics workspace will be deployed."
  default     = ""
}

variable "loganalytics_sku" {
  type        = string
  description = "Log Analytics workspace SKU."
  default     = "PerGB2018"
}

variable "loganalytics_retention_in_days" {
  type        = number
  description = "Retention in days for the Log Analytics workspace."
  default     = 30
}

variable "loganalytics_daily_quota_gb" {
  type        = number
  description = "Daily quota in GB for the Log Analytics workspace. Use -1 for unlimited."
  default     = -1
}

variable "loganalytics_internet_ingestion_enabled" {
  type        = bool
  description = "Whether public ingestion is enabled for the Log Analytics workspace."
  default     = true
}

variable "loganalytics_internet_query_enabled" {
  type        = bool
  description = "Whether public query is enabled for the Log Analytics workspace."
  default     = true
}

variable "loganalytics_local_authentication_disabled" {
  type        = bool
  description = "Whether local authentication is disabled for the Log Analytics workspace."
  default     = false
}

variable "loganalytics_reservation_capacity_in_gb_per_day" {
  type        = number
  description = "Optional commitment tier in GB/day for the Log Analytics workspace."
  default     = null
}

variable "loganalytics_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Log Analytics workspace."
  default     = {}
}

# -------------------------------------------------------------------
# End of Log Analytics Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Managed Identity Module Variables
# -------------------------------------------------------------------

variable "managed_identity_name" {
  type        = string
  description = "Name of the user-assigned managed identity to create."
  default     = "id-iactest-prod-001"
}

variable "managed_identity_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the managed identity will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "managed_identity_location" {
  type        = string
  description = "Optional override for the Azure region where the managed identity will be deployed. Leave empty to use the target resource group's location."
  default     = ""
}

variable "managed_identity_federated_identity_credentials" {
  type = map(object({
    audience = list(string)
    issuer   = string
    subject  = string
  }))
  description = "Optional map of federated identity credentials keyed by credential name."
  default     = {}
}

variable "managed_identity_role_assignments" {
  type = map(object({
    scope                = string
    role_definition_name = string
  }))
  description = "Optional map of role assignments keyed by assignment name."
  default     = {}
}

variable "managed_identity_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the managed identity."
  default     = {}
}

# -------------------------------------------------------------------
# End of Managed Identity Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Management Groups Module Variables
# -------------------------------------------------------------------

variable "management_group_name" {
  type        = string
  description = "Optional management group ID. Leave empty to let the module generate one from management_group_display_name."
  default     = ""
}

variable "management_group_display_name" {
  type        = string
  description = "Display name of the management group to create."
  default     = "Platform Landing Zone"
}

variable "management_group_parent_management_group_id" {
  type        = string
  description = "Optional parent management group resource ID. Leave empty to create the management group at the tenant root."
  default     = ""
}

variable "management_group_subscription_ids" {
  type        = list(string)
  description = "Optional list of subscription IDs to associate with the management group."
  default     = []
}

variable "management_group_tags" {
  type        = map(string)
  description = "Documentation tags to emit from the management group module."
  default     = {}
}

# -------------------------------------------------------------------
# End of Management Groups Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# NSG Module Variables
# -------------------------------------------------------------------

variable "nsg_name" {
  type        = string
  description = "Name of the Network Security Group to create."
  default     = "nsg-iactest-prod-001"
}

variable "nsg_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the NSG will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "nsg_location" {
  type        = string
  description = "Optional override for the Azure region where the NSG will be deployed. Leave empty to use the target resource group's location."
  default     = ""
}

variable "nsg_security_rules" {
  type = map(object({
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
    description                                = optional(string)
  }))
  description = "Map of NSG security rules keyed by rule name."
  default     = {}
}

variable "nsg_subnet_ids" {
  type        = list(string)
  description = "Optional subnet IDs to associate with the NSG."
  default     = []
}

variable "nsg_network_interface_ids" {
  type        = list(string)
  description = "Optional network interface IDs to associate with the NSG."
  default     = []
}

variable "nsg_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the NSG."
  default     = {}
}

# -------------------------------------------------------------------
# End of NSG Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# OpenAI Module Variables
# -------------------------------------------------------------------

variable "openai_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the Azure OpenAI account will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "openai_location" {
  type        = string
  description = "Optional override for the Azure region where the Azure OpenAI account will be deployed. Leave empty to use app_rg location."
  default     = ""
}

variable "openai_name" {
  type        = string
  description = "Azure OpenAI account name. Leave empty to auto-generate an account name."
  default     = ""
}

variable "openai_sku_name" {
  type        = string
  description = "SKU name for the Azure OpenAI account."
  default     = "S0"
}

variable "openai_custom_subdomain_name" {
  type        = string
  description = "Optional custom subdomain name for the Azure OpenAI account."
  default     = ""
}

variable "openai_public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled."
  default     = true
}

variable "openai_outbound_network_access_restricted" {
  type        = bool
  description = "Whether outbound network access is restricted."
  default     = false
}

variable "openai_local_auth_enabled" {
  type        = bool
  description = "Whether local authentication keys are enabled."
  default     = true
}

variable "openai_dynamic_throttling_enabled" {
  type        = bool
  description = "Whether dynamic throttling is enabled."
  default     = false
}

variable "openai_custom_question_answering_search_service_id" {
  type        = string
  description = "Optional Azure AI Search service ID for question answering."
  default     = ""
}

variable "openai_custom_question_answering_search_service_key" {
  type        = string
  description = "Optional Azure AI Search service key for question answering."
  default     = ""
  sensitive   = true
}

variable "openai_identity" {
  description = "Optional managed identity configuration."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null
}

variable "openai_customer_managed_key" {
  description = "Optional customer-managed key configuration."
  type = object({
    key_vault_key_id   = string
    identity_client_id = optional(string)
  })
  default = null
}

variable "openai_network_acls" {
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

variable "openai_enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Azure OpenAI account."
  default     = false
}

variable "openai_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""
}

variable "openai_private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "openai_private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve the private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "openai_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the private endpoint subnet."
  default     = ""
}

variable "openai_private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone ID to attach to the private endpoint."
  default     = ""
}

variable "openai_deployments" {
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
}

variable "openai_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Azure OpenAI account."
  default     = []
}

variable "openai_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Azure OpenAI account."
  default     = []
}

variable "openai_enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure OpenAI account."
  default     = false
}

variable "openai_log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID used when Azure OpenAI diagnostics are enabled."
  default     = ""
}

variable "openai_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable on the Azure OpenAI account."
  default     = []
}

variable "openai_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable on the Azure OpenAI account."
  default     = ["AllMetrics"]
}

variable "openai_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Azure OpenAI account."
  default     = {}
}

# -------------------------------------------------------------------
# End of OpenAI Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Policy Module Variables
# -------------------------------------------------------------------

variable "policy_name" {
  type        = string
  description = "Name of the custom policy definition."
  default     = "require-tag-owner"
}

variable "policy_display_name" {
  type        = string
  description = "Display name of the custom policy definition."
  default     = "Require Owner Tag"
}

variable "policy_description" {
  type        = string
  description = "Optional description for the custom policy definition."
  default     = ""
}

variable "policy_management_group_id" {
  type        = string
  description = "Optional management group resource ID used as the policy definition scope."
  default     = ""
}

variable "policy_rule" {
  type        = string
  description = "JSON policy rule string."
  default     = <<-EOT
{"if":{"field":"tags['Owner']","exists":"false"},"then":{"effect":"audit"}}
EOT
}

variable "policy_parameters" {
  type        = string
  description = "Optional JSON policy parameter schema string."
  default     = "{}"
}

variable "policy_metadata" {
  type        = string
  description = "Optional JSON metadata string for the policy definition."
  default     = "{\"category\":\"Tags\"}"
}

variable "policy_type" {
  type        = string
  description = "Policy type for the definition."
  default     = "Custom"
}

variable "policy_mode" {
  type        = string
  description = "Policy mode for the definition."
  default     = "All"
}

variable "policy_create_assignment" {
  type        = bool
  description = "Whether to create a policy assignment in addition to the definition."
  default     = false
}

variable "policy_assignment_scope" {
  type        = string
  description = "Optional scope for the policy assignment when policy_create_assignment is true."
  default     = ""
}

variable "policy_assignment_display_name" {
  type        = string
  description = "Optional display name for the policy assignment."
  default     = ""
}

variable "policy_assignment_description" {
  type        = string
  description = "Optional description for the policy assignment."
  default     = ""
}

variable "policy_assignment_parameters" {
  type        = string
  description = "Optional JSON parameters for the policy assignment."
  default     = "{}"
}

variable "policy_enforcement_mode" {
  type        = bool
  description = "Whether the assignment should enforce the policy."
  default     = true
}

variable "policy_location" {
  type        = string
  description = "Optional Azure region for policy assignments with managed identities."
  default     = ""
}

variable "policy_identity_type" {
  type        = string
  description = "Optional identity type for policy assignments. Leave empty to skip assignment identity."
  default     = ""
}

# -------------------------------------------------------------------
# End of Policy Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Private DNS Module Variables
# -------------------------------------------------------------------

variable "private_dns_resource_group_name" {
  type        = string
  description = "Optional override for the resource group containing the private DNS zones."
  default     = ""
}

variable "private_dns_zones" {
  type = map(object({
    soa_record = optional(object({
      email        = optional(string)
      expire_time  = optional(number)
      minimum_ttl  = optional(number)
      refresh_time = optional(number)
      retry_time   = optional(number)
      ttl          = optional(number)
      tags         = optional(map(string))
    }))
    vnet_links = optional(map(object({
      virtual_network_id   = string
      registration_enabled = optional(bool, false)
      tags                 = optional(map(string), {})
    })), {})
    a_records = optional(map(object({
      ttl     = number
      records = list(string)
      tags    = optional(map(string), {})
    })), {})
  }))
  description = "Private DNS zone definitions keyed by zone name."
  default     = {}
}

variable "private_dns_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to private DNS resources."
  default     = {}
}

# -------------------------------------------------------------------
# End of Private DNS Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Resource Group Module Variables
# -------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "Resource group name for the rg module test provision. Leave empty to auto-generate."
  default     = "rg-ba-cc-prd-shared-management-02"
}

variable "resource_group_location" {
  type        = string
  description = "The Azure region where the resource group will be deployed."
  default     = "canadacentral"
}

variable "resource_group_enable_lock" {
  type        = bool
  description = "Whether to create a management lock on the resource group."
  default     = false
}

variable "resource_group_lock_level" {
  type        = string
  description = "Management lock level when resource_group_enable_lock is true."
  default     = "CanNotDelete"
}

variable "resource_group_lock_notes" {
  type        = string
  description = "Optional notes for the management lock."
  default     = ""
}

variable "resource_group_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the resource group."
  default     = []
}

variable "resource_group_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the resource group."
  default     = []
}

variable "resource_group_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource group."
  default     = {}
}

# -------------------------------------------------------------------
# End of Resource Group Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Role Assignments Module Variables
# -------------------------------------------------------------------

variable "roleassignments_assignments" {
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
  description = "Role assignments keyed by assignment name."
  default     = {}
}

# -------------------------------------------------------------------
# End of Role Assignments Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Route Table Module Variables
# -------------------------------------------------------------------

variable "route_table_name" {
  type        = string
  description = "Route table name."
  default     = "rt-iactest-prod-001"
}

variable "route_table_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the route table will be deployed."
  default     = ""
}

variable "route_table_location" {
  type        = string
  description = "Optional override for the Azure region where the route table will be deployed."
  default     = ""
}

variable "route_table_disable_bgp_route_propagation" {
  type        = bool
  description = "Whether BGP route propagation is disabled on the route table."
  default     = false
}

variable "route_table_routes" {
  type = map(object({
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  description = "User-defined routes keyed by route name."
  default     = {}
}

variable "route_table_subnet_ids" {
  type        = list(string)
  description = "Subnet IDs to associate with the route table."
  default     = []
}

variable "route_table_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the route table."
  default     = {}
}

# -------------------------------------------------------------------
# End of Route Table Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Service Bus Module Variables
# -------------------------------------------------------------------

variable "servicebus_resource_group_name" {
  type        = string
  description = "Optional override for the resource group where the Service Bus namespace will be deployed. Leave empty to use app_rg."
  default     = ""
}

variable "servicebus_location" {
  type        = string
  description = "Optional override for the Azure region where the Service Bus namespace will be deployed. Leave empty to use app_rg location."
  default     = ""
}

variable "servicebus_name" {
  type        = string
  description = "Service Bus namespace name. Leave empty to auto-generate a namespace name."
  default     = ""
}

variable "servicebus_sku" {
  type        = string
  description = "Service Bus namespace SKU."
  default     = "Standard"
}

variable "servicebus_capacity" {
  type        = number
  description = "Service Bus namespace capacity."
  default     = 0
}

variable "servicebus_premium_messaging_partitions" {
  type        = number
  description = "Premium messaging partitions when using Premium SKU."
  default     = 0
}

variable "servicebus_local_auth_enabled" {
  type        = bool
  description = "Whether SAS/local authentication is enabled for the Service Bus namespace."
  default     = true
}

variable "servicebus_public_network_access_enabled" {
  type        = bool
  description = "Whether public network access is enabled for the Service Bus namespace."
  default     = true
}

variable "servicebus_minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the Service Bus namespace."
  default     = "1.2"
}

variable "servicebus_system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the Service Bus namespace."
  default     = false
}

variable "servicebus_enable_network_rule_set" {
  type        = bool
  description = "Whether to configure network rules on the Service Bus namespace."
  default     = false
}

variable "servicebus_network_rule_default_action" {
  type        = string
  description = "Default action for the Service Bus namespace network rule set."
  default     = "Allow"
}

variable "servicebus_network_rule_ip_rules" {
  type        = list(string)
  description = "Allowed IP rules for the Service Bus namespace network rule set."
  default     = []
}

variable "servicebus_trusted_services_allowed" {
  type        = bool
  description = "Whether trusted Microsoft services are allowed through the Service Bus network rule set."
  default     = false
}

variable "servicebus_network_rules" {
  type = list(object({
    subnet_id                            = string
    ignore_missing_vnet_service_endpoint = optional(bool, false)
  }))
  description = "Optional subnet-based network rules for the Service Bus namespace."
  default     = []
}

variable "servicebus_queues" {
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    max_delivery_count                      = optional(number, 10)
    lock_duration                           = optional(string, "PT1M")
    default_message_ttl                     = optional(string, "P14D")
    auto_delete_on_idle                     = optional(string)
    dead_lettering_on_message_expiration    = optional(bool, true)
    duplicate_detection_history_time_window = optional(string)
    requires_duplicate_detection            = optional(bool, false)
    requires_session                        = optional(bool, false)
    partitioning_enabled                    = optional(bool, false)
    express_enabled                         = optional(bool, false)
    batched_operations_enabled              = optional(bool, true)
    status                                  = optional(string, "Active")
    forward_to                              = optional(string)
    forward_dead_lettered_messages_to       = optional(string)
  }))
  description = "Map of Service Bus queues keyed by queue name."
  default     = {}
}

variable "servicebus_topics" {
  type = map(object({
    max_size_in_megabytes                   = optional(number, 1024)
    default_message_ttl                     = optional(string, "P14D")
    auto_delete_on_idle                     = optional(string)
    duplicate_detection_history_time_window = optional(string)
    requires_duplicate_detection            = optional(bool, false)
    partitioning_enabled                    = optional(bool, false)
    express_enabled                         = optional(bool, false)
    batched_operations_enabled              = optional(bool, true)
    support_ordering                        = optional(bool, false)
    status                                  = optional(string, "Active")
  }))
  description = "Map of Service Bus topics keyed by topic name."
  default     = {}
}

variable "servicebus_subscriptions" {
  type = map(object({
    topic_name                                = string
    max_delivery_count                        = optional(number, 10)
    lock_duration                             = optional(string, "PT1M")
    default_message_ttl                       = optional(string, "P14D")
    auto_delete_on_idle                       = optional(string)
    dead_lettering_on_message_expiration      = optional(bool, true)
    dead_lettering_on_filter_evaluation_error = optional(bool, false)
    requires_session                          = optional(bool, false)
    batched_operations_enabled                = optional(bool, true)
    status                                    = optional(string, "Active")
    forward_to                                = optional(string)
    forward_dead_lettered_messages_to         = optional(string)
    client_scoped_subscription_enabled        = optional(bool, false)
  }))
  description = "Map of Service Bus subscriptions keyed by subscription name."
  default     = {}
}

variable "servicebus_authorization_rules" {
  type = map(object({
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
  }))
  description = "Optional namespace authorization rules keyed by rule name."
  default     = {}
}

variable "servicebus_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the Service Bus namespace."
  default     = []
}

variable "servicebus_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the Service Bus namespace."
  default     = []
}

variable "servicebus_enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Service Bus namespace."
  default     = false
}

variable "servicebus_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the Service Bus private endpoint."
  default     = ""
}

variable "servicebus_private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the Service Bus private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "servicebus_private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve the Service Bus private endpoint subnet when subnet ID is not provided."
  default     = ""
}

variable "servicebus_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the Service Bus private endpoint subnet."
  default     = ""
}

variable "servicebus_private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone ID to attach to the Service Bus private endpoint."
  default     = ""
}

variable "servicebus_enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Service Bus namespace."
  default     = false
}

variable "servicebus_log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID used when Service Bus diagnostics are enabled."
  default     = ""
}

variable "servicebus_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable on the Service Bus namespace."
  default     = ["OperationalLogs"]
}

variable "servicebus_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable on the Service Bus namespace."
  default     = ["AllMetrics"]
}

variable "servicebus_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Service Bus namespace."
  default     = {}
}

# -------------------------------------------------------------------
# End of Service Bus Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# SQL DB Module Variables
# -------------------------------------------------------------------

variable "sqldb_tags" {
  type = map(any)
  default = {
    "resourceType" = "SQLDB"
  }
}

variable "app_sqlserver_name" {
  type        = string
  description = "The name of the Azure SQL Server to be created."
  default     = null
}

variable "app_sqldb_name" {
  type        = string
  description = "The name of the Azure SQL db inside the server to be created.."
  default     = null
}

variable "sqldb_app_admin_group" {
  description = "Microsoft Entra groups granted Contributor on the SQL Server resource."
  type        = list(string)
  default     = []
}

variable "sqldb_app_user_group" {
  description = "Microsoft Entra groups granted Reader on the SQL Server resource."
  type        = list(string)
  default     = []
}

variable "sql_ad_group" {
  type        = string
  description = "The name of the group that will have admin access to the SQL server."
  default     = "BA-G-Azure-Owner-F"
}

variable "sql_ad_group_id" {
  type        = string
  description = "The id of the group that will have admin access to the SQL server."
  default     = "962b2502-5355-48bd-a33e-9280db2ac892"
}

variable "enable_private_endpoint" {
  description = "Legacy SQL DB compatibility input for enabling a private endpoint."
  type        = bool
  default     = true
}

variable "private_endpoint_subnet_id" {
  description = "Legacy SQL DB compatibility input for the private endpoint subnet ID."
  type        = string
  default     = ""
}

# -------------------------------------------------------------------
# End of SQL DB Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# SQL Managed Instance Module Variables
# -------------------------------------------------------------------

variable "sqlmi_tags" {
  type = map(any)
  default = {
    "resourceType" = "SQLMI"
  }
}

variable "sqlmi_name" {
  description = "Optional override for the SQL Managed Instance name."
  type        = string
  default     = ""
}

variable "sqlmi_resource_group_name" {
  description = "Optional override for the SQL Managed Instance resource group. Leave empty to use app_rg."
  type        = string
  default     = ""
}

variable "sqlmi_location" {
  description = "Optional override for the SQL Managed Instance location. Leave empty to use the effective resource group location."
  type        = string
  default     = ""
}

variable "sqlmi_subnet_id" {
  description = "Delegated subnet resource ID for the SQL Managed Instance."
  type        = string
  default     = ""
}

variable "sqlmi_administrator_login" {
  description = "Administrator login for the SQL Managed Instance."
  type        = string
  default     = "sqladminuser"
}

variable "sqlmi_administrator_login_password" {
  description = "Optional override for the SQL Managed Instance administrator password. Leave empty to use the sqladminuser-password secret from the IAC Key Vault."
  type        = string
  default     = ""
  sensitive   = true
}

variable "sqlmi_sku_name" {
  description = "SKU name for SQL Managed Instance."
  type        = string
  default     = "GP_Gen5"
}

variable "sqlmi_license_type" {
  description = "License type for SQL Managed Instance."
  type        = string
  default     = "BasePrice"
}

variable "sqlmi_vcores" {
  description = "vCore count for SQL Managed Instance."
  type        = number
  default     = 8
}

variable "sqlmi_storage_size_in_gb" {
  description = "Storage size in GB for SQL Managed Instance."
  type        = number
  default     = 512
}

variable "sqlmi_collation" {
  description = "Collation for SQL Managed Instance."
  type        = string
  default     = "SQL_Latin1_General_CP1_CI_AS"
}

variable "sqlmi_minimum_tls_version" {
  description = "Minimum TLS version for SQL Managed Instance."
  type        = string
  default     = "1.2"
}

variable "sqlmi_timezone_id" {
  description = "Timezone ID for SQL Managed Instance."
  type        = string
  default     = "UTC"
}

variable "sqlmi_public_data_endpoint_enabled" {
  description = "Whether the public data endpoint is enabled for SQL Managed Instance."
  type        = bool
  default     = false
}

variable "sqlmi_proxy_override" {
  description = "Proxy override mode for SQL Managed Instance."
  type        = string
  default     = "Proxy"
}

variable "sqlmi_storage_account_type" {
  description = "Underlying storage account type for SQL Managed Instance."
  type        = string
  default     = "GRS"
}

variable "sqlmi_maintenance_configuration_name" {
  description = "Optional maintenance configuration name for SQL Managed Instance."
  type        = string
  default     = null
}

variable "sqlmi_zone_redundant_enabled" {
  description = "Whether zone redundancy is enabled for SQL Managed Instance."
  type        = bool
  default     = false
}

variable "sqlmi_dns_zone_partner_id" {
  description = "Optional partner SQL Managed Instance ID for DNS zone sharing."
  type        = string
  default     = null
}

variable "sqlmi_identity_type" {
  description = "Managed identity type for SQL Managed Instance."
  type        = string
  default     = "SystemAssigned"
}

variable "sqlmi_identity_ids" {
  description = "User-assigned identity resource IDs for SQL Managed Instance."
  type        = set(string)
  default     = []
}

variable "sqlmi_azure_active_directory_administrator" {
  description = "Optional Microsoft Entra administrator block for SQL Managed Instance."
  type = object({
    login_username                      = string
    object_id                           = string
    principal_type                      = string
    tenant_id                           = optional(string)
    azuread_authentication_only_enabled = optional(bool, false)
  })
  default = null
}

variable "sqlmi_app_admin_group" {
  description = "Microsoft Entra groups granted Contributor on the SQL Managed Instance resource."
  type        = list(string)
  default     = []
}

variable "sqlmi_app_user_group" {
  description = "Microsoft Entra groups granted Reader on the SQL Managed Instance resource."
  type        = list(string)
  default     = []
}

variable "sqlmi_enable_diagnostics" {
  description = "Enable diagnostics for the SQL Managed Instance module."
  type        = bool
  default     = false
}

variable "sqlmi_log_analytics_workspace_id" {
  description = "Optional override for the Log Analytics workspace resource ID used by sqlmi diagnostics."
  type        = string
  default     = ""
}

variable "sqlmi_diagnostic_log_categories" {
  description = "Diagnostic log categories for the SQL Managed Instance."
  type        = list(string)
  default     = ["ResourceUsageStats", "SQLSecurityAuditEvents", "DevOpsOperationsAudit"]
}

variable "sqlmi_diagnostic_metric_categories" {
  description = "Diagnostic metric categories for the SQL Managed Instance."
  type        = list(string)
  default     = ["AllMetrics"]
}

# -------------------------------------------------------------------
# End of SQL Managed Instance Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# SQL Managed Instance Database Module Variables
# -------------------------------------------------------------------

variable "sqlmidb_tags" {
  type = map(any)
  default = {
    "ResourceType"                            = "SQLMIDB"
    "Tier2:Application Name"                  = "CCOE INFRA IAC"
    "Tier2:Application Owner"                 = "CCOE"
    "Tier2:AppSupport Team"                   = "CCOE"
    "Tier2:Approval Group"                    = "CCOE"
    "Tier2:Business Owner"                    = "CCOE"
    "Tier2:Environment"                       = "Dev"
    "Tier2:InfraSupport Team"                 = "CCOE"
    "Tier2:Maintenance Window"                = "CCOE"
    "Tier2:Project Name"                      = "CCOE INFRA IAC"
    "Tier2:Project Number"                    = "N/A"
    "Tier2:RPO-RTO"                           = "48H/24H"
    "Tier2:Run Cost(Approved Run Budget)-USD" = "100"
    "Tier2:workload"                          = "iactest"
    "Tier2:Requested By"                      = "CCOE"
    "Tier2:Provisioned By"                    = "admin@2join.us"
    "Tier2:Technical contact"                 = "admin@2join.us"
    "Tier2:Business contact"                  = "admin@2join.us"
    "Tier2:ADO Project"                       = "CCoE-Infra-IaC"
    "Tier2:ADO Repo"                          = "adf-lab"
    "Tier2:ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/adf-lab"
  }
}

variable "app_sqlmi" {
  type        = string
  description = "The name of the Azure SQL Managed Instance to be created."
  default     = null
}

variable "app_sqlmi_db" {
  type        = string
  description = "The name of the Azure SQL Managed Database to be created."
  default     = null
}

variable "app_sqlmi_rg" {
  type        = string
  description = "The rg name of the Azure SQL Managed Database to be created."
  default     = null
}

variable "sqlmi_db_enable_diagnostics" {
  description = "Enable diagnostics for the SQL Managed Instance database module."
  type        = bool
  default     = false
}

variable "sqlmi_db_log_analytics_workspace_id" {
  description = "Optional override for the Log Analytics workspace resource ID used by sqlmi_db diagnostics."
  type        = string
  default     = ""
}

variable "sqlmi_db_diagnostic_log_categories" {
  description = "Diagnostic log categories for the SQL Managed Instance database."
  type        = list(string)
  default     = ["SQLSecurityAuditEvents"]
}

variable "sqlmi_db_diagnostic_metric_categories" {
  description = "Diagnostic metric categories for the SQL Managed Instance database."
  type        = list(string)
  default     = ["AllMetrics"]
}

variable "sqlmi_db_app_admin_group" {
  description = "Microsoft Entra groups granted Contributor on the SQL Managed Database resource."
  type        = list(string)
  default     = []
}

variable "sqlmi_db_app_user_group" {
  description = "Microsoft Entra groups granted Reader on the SQL Managed Database resource."
  type        = list(string)
  default     = []
}

# -------------------------------------------------------------------
# End of SQL Managed Instance Database Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Storage Account Module Variables
# -------------------------------------------------------------------

variable "storage_account_resource_group_name" {
  type        = string
  description = "The name of the resource group where the storage account will be deployed."
  default     = null
}

variable "storage_account_location" {
  type        = string
  description = "The Azure region where to deploy the storage account."
  default     = "canadacentral"
}

variable "storage_account_name" {
  type        = string
  description = "Storage account name."
  default     = "stiactestprod001"

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 lowercase alphanumeric characters."
  }
}

variable "storage_account_account_tier" {
  type        = string
  description = "Defines the storage account tier."
  default     = "Standard"
}

variable "storage_account_account_replication_type" {
  type        = string
  description = "Defines the replication type for the storage account."
  default     = "LRS"
}

variable "storage_account_account_kind" {
  type        = string
  description = "Defines the storage account kind."
  default     = "StorageV2"
}

variable "storage_account_access_tier" {
  type        = string
  description = "Access tier for Standard StorageV2 or BlobStorage accounts."
  default     = "Hot"
}

variable "storage_account_min_tls_version" {
  type        = string
  description = "The minimum supported TLS version."
  default     = "TLS1_2"
}

variable "storage_account_https_traffic_only_enabled" {
  type        = bool
  description = "Whether to require HTTPS traffic only."
  default     = true
}

variable "storage_account_public_network_access_enabled" {
  type        = bool
  description = "Whether the storage account public endpoint is reachable."
  default     = false
}

variable "storage_account_allow_nested_items_to_be_public" {
  type        = bool
  description = "Whether nested blobs and containers can be made public."
  default     = false
}

variable "storage_account_shared_access_key_enabled" {
  type        = bool
  description = "Whether shared access keys are enabled."
  default     = true
}

variable "storage_account_cross_tenant_replication_enabled" {
  type        = bool
  description = "Whether cross-tenant replication is enabled."
  default     = false
}

variable "storage_account_infrastructure_encryption_enabled" {
  type        = bool
  description = "Whether infrastructure encryption is enabled."
  default     = false
}

variable "storage_account_is_hns_enabled" {
  type        = bool
  description = "Whether hierarchical namespace is enabled."
  default     = false
}

variable "storage_account_nfsv3_enabled" {
  type        = bool
  description = "Whether NFSv3 is enabled."
  default     = false
}

variable "storage_account_sftp_enabled" {
  type        = bool
  description = "Whether SFTP is enabled."
  default     = false
}

variable "storage_account_local_user_enabled" {
  type        = bool
  description = "Whether local users are enabled for the storage account."
  default     = false
}

variable "storage_account_system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity."
  default     = false
}

variable "storage_account_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the storage account. Prefer object IDs when display names are not unique."
  default     = null
}

variable "storage_account_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the storage account. Prefer object IDs when display names are not unique."
  default     = null
}

variable "storage_account_managed_identity_role_assignments" {
  type = map(object({
    scope                = string
    role_definition_name = optional(string)
    role_definition_id   = optional(string)
  }))
  description = "Role assignments to apply to the system-assigned managed identity."
  default     = {}
}

variable "storage_account_enable_network_rules" {
  type        = bool
  description = "Whether to manage storage account network rules."
  default     = false
}

variable "storage_account_network_rules_default_action" {
  type        = string
  description = "Default action for storage account network rules."
  default     = "Deny"
}

variable "storage_account_network_rules_bypass" {
  type        = list(string)
  description = "Traffic classes to bypass the network rules."
  default     = ["AzureServices"]
}

variable "storage_account_network_rules_ip_rules" {
  type        = list(string)
  description = "IPv4 addresses or CIDR ranges allowed by network rules."
  default     = []
}

variable "storage_account_network_rules_virtual_network_subnet_ids" {
  type        = list(string)
  description = "Subnet resource IDs allowed by network rules."
  default     = []
}

variable "storage_account_private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""
}

variable "storage_account_private_endpoint_subnet_name" {
  type        = string
  description = "Existing subnet name used for private endpoint lookup."
  default     = null
}

variable "storage_account_private_endpoint_vnet_name" {
  type        = string
  description = "Existing virtual network name used for private endpoint subnet lookup."
  default     = null
}

variable "storage_account_private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used for private endpoint subnet lookup."
  default     = null
}

variable "storage_account_private_endpoint_subresource_names" {
  type        = list(string)
  description = "Storage private endpoint subresources to create."
  default     = []
}

variable "storage_account_private_dns_zone_ids" {
  type        = map(string)
  description = "Optional private DNS zone IDs keyed by private endpoint subresource name."
  default     = {}
}

variable "storage_account_private_dns_zone_names" {
  type        = map(string)
  description = "Optional private DNS zone names keyed by private endpoint subresource name."
  default     = {}
}

variable "storage_account_private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group containing the private DNS zones used for storage account private endpoints."
  default     = null
}

variable "storage_account_enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the storage account."
  default     = false
}

variable "storage_account_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by storage account diagnostics. Leave empty to use data.azurerm_log_analytics_workspace.this.id."
  default     = ""
}

variable "storage_account_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = ["StorageRead", "StorageWrite", "StorageDelete"]
}

variable "storage_account_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["Transaction"]
}

variable "storage_account_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the storage account."
  default     = {}
}

# -------------------------------------------------------------------
# End of Storage Account Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Subscription Vending Module Variables
# -------------------------------------------------------------------

variable "subscription_vending_subscription_alias_enabled" {
  type        = bool
  description = "Whether to create a subscription alias and a new subscription."
  default     = false
}

variable "subscription_vending_subscription_alias_name" {
  type        = string
  description = "Subscription alias name when creating a new subscription."
  default     = ""
}

variable "subscription_vending_subscription_name" {
  type        = string
  description = "Subscription display name."
  default     = "platform-iactest-prod"
}

variable "subscription_vending_billing_scope_id" {
  type        = string
  description = "Billing scope ID used when creating a new subscription alias."
  default     = ""
}

variable "subscription_vending_existing_subscription_id" {
  type        = string
  description = "Existing subscription ID used when bootstrapping an existing subscription."
  default     = ""
}

variable "subscription_vending_management_group_id" {
  type        = string
  description = "Management group ID used to associate the subscription."
  default     = ""
}

variable "subscription_vending_resource_provider_registrations" {
  type        = list(string)
  description = "Resource providers to register in the target subscription."
  default     = []
}

variable "subscription_vending_bootstrap_resource_groups" {
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
  description = "Bootstrap resource groups to create in the target subscription."
  default     = {}
}

variable "subscription_vending_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to bootstrap resource groups."
  default     = {}
}

# -------------------------------------------------------------------
# End of Subscription Vending Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Virtual Network Module Variables
# -------------------------------------------------------------------

variable "vnet_resource_group_name" {
  type        = string
  description = "The name of the resource group where the virtual network will be deployed."
  default     = "rg-ba-cc-prd-shared-management"
}

variable "vnet_location" {
  type        = string
  description = "The Azure region where to deploy the virtual network."
  default     = "canadacentral"
}

variable "vnet_name" {
  type        = string
  description = "Virtual network name. Leave empty to auto-generate."
  default     = "vnet-ba-cc-prd-shared-management-01"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address spaces applied to the virtual network."
  default     = ["10.250.0.0/16"]
}

variable "vnet_dns_servers" {
  type        = list(string)
  description = "Optional custom DNS server IP addresses for the virtual network."
  default     = []
}

variable "vnet_bgp_community" {
  type        = string
  description = "Optional BGP community value for the virtual network."
  default     = null
}

variable "vnet_edge_zone" {
  type        = string
  description = "Optional Edge Zone where the virtual network will be deployed."
  default     = null
}

variable "vnet_flow_timeout_in_minutes" {
  type        = number
  description = "Optional flow timeout in minutes for the virtual network."
  default     = null
}

variable "vnet_ddos_protection_plan_id" {
  type        = string
  description = "Optional DDoS protection plan ID to associate with the virtual network."
  default     = ""
}

variable "vnet_subnets" {
  type = map(object({
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    service_endpoint_policy_ids                   = optional(list(string), [])
    private_endpoint_network_policies             = optional(string, "Enabled")
    private_link_service_network_policies_enabled = optional(bool, true)
    delegations = optional(map(object({
      name                    = string
      service_delegation_name = string
      actions                 = optional(list(string), [])
    })), {})
  }))
  description = "Optional subnet definitions keyed by subnet name."
  default     = {}
}

variable "vnet_app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the virtual network."
  default     = []
}

variable "vnet_app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the virtual network."
  default     = []
}

variable "vnet_enable_diagnostics" {
  type        = bool
  description = "Enable diagnostic settings for the virtual network."
  default     = false
}

variable "vnet_log_analytics_workspace_id" {
  type        = string
  description = "Optional override for the Log Analytics workspace resource ID used by virtual network diagnostics. Leave empty to use data.azurerm_log_analytics_workspace.this.id."
  default     = ""
}

variable "vnet_diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable."
  default     = []
}

variable "vnet_diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
}

variable "vnet_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the virtual network."
  default     = {}
}

# -------------------------------------------------------------------
# End of Virtual Network Module Variables
# -------------------------------------------------------------------

# -------------------------------------------------------------------
# Windows VM Module Variables
# -------------------------------------------------------------------

variable "app_vnet" {
  type        = string
  description = "The name of the virtual network in which the resources will be created."
  default     = null

  validation {
    condition     = var.app_vnet != null && trimspace(var.app_vnet) != ""
    error_message = "app_vnet is required."
  }
}

variable "app_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
  default     = null

  validation {
    condition     = var.app_rg != null && trimspace(var.app_rg) != ""
    error_message = "app_rg is required."
  }

}

variable "app_vm" {
  type        = string
  description = "The name of the virtual machine to be created."
  default     = null
}

variable "app_vm_number" {
  type        = number
  description = "The number of virtual machines to be created."
  default     = 1
}

variable "app_vm_size" {
  type        = string
  description = "The size of the virtual machine to be created."
  default     = "Standard_D2s_v3"
}

variable "app_snet" {
  type        = string
  description = "The name of the subnet in which the resources will be created."
  default     = null

  validation {
    condition     = var.app_snet != null && trimspace(var.app_snet) != ""
    error_message = "app_snet is required."
  }
}

variable "db_snet" {
  type        = string
  description = "The name of the DB subnet in which the resources will be created."
  default     = null
}

variable "app_vnet_rg" {
  type        = string
  description = "The name of the resource group in which the virtual network is located."
  default     = null

  validation {
    condition     = var.app_vnet_rg != null && trimspace(var.app_vnet_rg) != ""
    error_message = "app_vnet_rg is required."
  }
}

variable "app_remote_group" {
  type        = list(string)
  description = "The list of groups that will have remote access to the resources."
  default     = ["BA-G-Azure-Owner-F"]
}

variable "app_admin_group" {
  type        = list(string)
  description = "The list of groups that will have administrator access to the Windows VM resources."
  default     = ["BA-G-Azure-Owner-F"]
}

variable "app_user_group" {
  type        = list(string)
  description = "The list of groups that will have Reader access to the Windows VM resources."
  default     = ["BA-G-Azure-Owner-F"]
}

variable "app_ad_group" {
  type        = string
  description = "The name of the group that will have reader access to the resources."
  default     = "BA-G-Azure-Owner-F"
}

variable "app_ad_group_id" {
  type        = string
  description = "Optional object ID for the reader access group. Prefer this when the display name is duplicated in Entra ID."
  default     = ""
}

variable "vm_remote_group" {
  type        = string
  description = "The group that receives the Virtual Machine User Login role on each Windows VM."
  default     = "BA-G-Azure-Owner-F"
}

variable "vm_admin_group" {
  type        = string
  description = "The group that receives the Virtual Machine Administrator Login role on each Windows VM."
  default     = "BA-G-Azure-Owner-F"
}

variable "app_rgadmin_group" {
  type        = string
  description = "The name of the group that will have administrative access to the resources."
  default     = "BA-G-Azure-Owner-F"
}

variable "disksize" {
  type        = number
  description = "The size of the disk to be attached to the virtual machine."
  default     = 0
}

variable "public_network_enabled" {
  type    = bool
  default = false
}

variable "AADLoginForWindows" {
  description = "Whether to install the Microsoft Entra login extension on the Windows VM."
  type        = bool
  default     = true
}

variable "enable_domain_join" {
  description = "Whether to join the Windows VM to the domain through JsonADDomainExtension."
  type        = bool
  default     = false
}

variable "enable_custom_script_extension" {
  description = "Whether to attach the Windows VM CustomScriptExtension. Default is false, which skips the custom bootstrap script and the extension."
  type        = bool
  default     = false
}

variable "enable_diagnostics" {
  description = "Whether to expose diagnostics intent for the Windows VM module."
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Optional override for the Log Analytics workspace resource ID used with external Windows VM diagnostics."
  type        = string
  default     = ""
}

variable "adf_id" {
  description = "Optional Azure Data Factory resource ID used for SHIR RBAC."
  type        = string
  default     = null
}

variable "enable_shir" {
  description = "Whether the Windows VM should enable Self Hosted Integration Runtime logic and related ADF RBAC."
  type        = bool
  default     = false
}

variable "winvm_tags" {
  description = "Additional tags for the Windows VM module."
  type        = map(string)
  default = {
    resourceType = "WINVM"
  }
}

# -------------------------------------------------------------------
# End of Windows VM Module Variables
# -------------------------------------------------------------------

