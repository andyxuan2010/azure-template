variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the AKS cluster will be deployed."

  validation {
    condition     = length(trimspace(var.resource_group_name)) > 0
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  type        = string
  description = "The Azure region where to deploy the AKS cluster. If empty, the resource group's location is used."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "AKS cluster name. If empty, the module auto-generates one."
  default     = ""

  validation {
    condition     = var.name == "" || can(regex("^[A-Za-z0-9][A-Za-z0-9-_]{0,62}$", var.name))
    error_message = "name must be empty or 1-63 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "node_resource_group_name" {
  type        = string
  description = "Optional custom node resource group name for AKS managed infrastructure. When empty, Azure generates the node resource group."
  default     = ""

  validation {
    condition     = trimspace(var.node_resource_group_name) == "" || can(regex("^[A-Za-z0-9._()\\-]{1,80}$", trimspace(var.node_resource_group_name)))
    error_message = "node_resource_group_name must be empty or a valid Azure resource group name."
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

variable "dns_prefix" {
  type        = string
  description = "Optional DNS prefix for the AKS API server. If empty, the module derives one from the cluster name."
  default     = ""

  validation {
    condition     = var.dns_prefix == "" || can(regex("^[a-z0-9-]{1,54}$", var.dns_prefix))
    error_message = "dns_prefix must be empty or 1-54 lowercase alphanumeric or hyphen characters."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Optional Kubernetes version for the AKS control plane."
  default     = null
}

variable "sku_tier" {
  type        = string
  description = "AKS SKU tier."
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Free, Standard, or Premium."
  }
}

variable "automatic_upgrade_channel" {
  type        = string
  description = "Automatic upgrade channel for AKS."
  default     = "patch"

  validation {
    condition     = contains(["patch", "rapid", "stable", "node-image", "none"], var.automatic_upgrade_channel)
    error_message = "automatic_upgrade_channel must be patch, rapid, stable, node-image, or none."
  }
}

variable "node_os_upgrade_channel" {
  type        = string
  description = "Node OS image upgrade channel for AKS node pools."
  default     = "NodeImage"

  validation {
    condition     = contains(["NodeImage", "SecurityPatch", "Unmanaged", "None"], var.node_os_upgrade_channel)
    error_message = "node_os_upgrade_channel must be NodeImage, SecurityPatch, Unmanaged, or None."
  }
}

variable "private_cluster_enabled" {
  type        = bool
  description = "Whether the AKS cluster API server is private."
  default     = true
}

variable "private_cluster_public_fqdn_enabled" {
  type        = bool
  description = "Whether a private AKS cluster also exposes a public FQDN endpoint."
  default     = false
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional private DNS zone resource ID for a private AKS cluster. If empty, the module can use private_dns_zone_name/resource_group_name or fall back to System."
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
  description = "Optional existing private DNS zone name used when private_dns_zone_id is not supplied."
  default     = ""
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Optional resource group containing private_dns_zone_name."
  default     = ""

  validation {
    condition = (
      (trimspace(var.private_dns_zone_name) == "" && trimspace(var.private_dns_zone_resource_group_name) == "") ||
      (trimspace(var.private_dns_zone_name) != "" && trimspace(var.private_dns_zone_resource_group_name) != "")
    )
    error_message = "private_dns_zone_name and private_dns_zone_resource_group_name must either both be set or both be empty."
  }
}

variable "role_based_access_control_enabled" {
  type        = bool
  description = "Whether Kubernetes RBAC is enabled."
  default     = true
}

variable "azure_rbac_enabled" {
  type        = bool
  description = "Whether Azure RBAC for Kubernetes Authorization is enabled."
  default     = true

  validation {
    condition     = !var.azure_rbac_enabled || var.role_based_access_control_enabled
    error_message = "azure_rbac_enabled can only be true when role_based_access_control_enabled is true."
  }
}

variable "local_account_disabled" {
  type        = bool
  description = "Whether local AKS admin accounts are disabled."
  default     = true
}

variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "Optional list of CIDR ranges allowed to reach the AKS API server when the cluster is public."
  default     = []

  validation {
    condition = alltrue([
      for cidr in var.api_server_authorized_ip_ranges :
      can(cidrhost(cidr, 0))
    ])
    error_message = "api_server_authorized_ip_ranges must contain valid CIDR ranges."
  }
}

variable "oidc_issuer_enabled" {
  type        = bool
  description = "Whether the cluster OIDC issuer is enabled."
  default     = true
}

variable "workload_identity_enabled" {
  type        = bool
  description = "Whether AKS Workload Identity is enabled."
  default     = true

  validation {
    condition     = !var.workload_identity_enabled || var.oidc_issuer_enabled
    error_message = "workload_identity_enabled can only be true when oidc_issuer_enabled is true."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive AKS cluster admin access."
  default     = []
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive Reader access on the AKS cluster resource."
  default     = []
}

variable "terraform_execution_aks_role" {
  type        = string
  description = "Optional Azure Kubernetes Service RBAC role to assign to the current Terraform execution identity on the AKS cluster. Set to Azure Kubernetes Service RBAC Cluster Admin or Azure Kubernetes Service RBAC Cluster Writer to enable kubectl access for the Terraform service principal."
  default     = ""

  validation {
    condition = contains([
      "",
      "Azure Kubernetes Service RBAC Cluster Admin",
      "Azure Kubernetes Service RBAC Cluster Writer"
    ], var.terraform_execution_aks_role)
    error_message = "terraform_execution_aks_role must be empty, Azure Kubernetes Service RBAC Cluster Admin, or Azure Kubernetes Service RBAC Cluster Writer."
  }

  validation {
    condition     = var.terraform_execution_aks_role == "" || var.azure_rbac_enabled
    error_message = "terraform_execution_aks_role can only be set when azure_rbac_enabled is true."
  }
}

variable "default_node_pool" {
  description = "Default node pool configuration."
  type = object({
    name                         = optional(string, "system")
    vm_size                      = optional(string, "Standard_D4s_v5")
    node_count                   = optional(number, 1)
    enable_auto_scaling          = optional(bool, false)
    min_count                    = optional(number)
    max_count                    = optional(number)
    zones                        = optional(list(string), [])
    os_disk_size_gb              = optional(number, 128)
    os_disk_type                 = optional(string, "Managed")
    max_pods                     = optional(number)
    vnet_subnet_id               = optional(string)
    only_critical_addons_enabled = optional(bool, false)
    orchestrator_version         = optional(string)
    os_sku                       = optional(string, "Ubuntu")
    type                         = optional(string, "VirtualMachineScaleSets")
    temporary_name_for_rotation  = optional(string)
    host_encryption_enabled      = optional(bool, false)
    ultra_ssd_enabled            = optional(bool, false)
    upgrade_settings = optional(object({
      max_surge                     = optional(string)
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
    }))
  })
  default = {}

  validation {
    condition     = can(regex("^[a-z0-9]{1,12}$", var.default_node_pool.name))
    error_message = "default_node_pool.name must be 1-12 lowercase alphanumeric characters."
  }

  validation {
    condition     = var.default_node_pool.node_count >= 1
    error_message = "default_node_pool.node_count must be at least 1."
  }

  validation {
    condition     = !var.default_node_pool.enable_auto_scaling || (try(var.default_node_pool.min_count, null) != null && try(var.default_node_pool.max_count, null) != null)
    error_message = "default_node_pool.min_count and default_node_pool.max_count are required when enable_auto_scaling is true."
  }

  validation {
    condition = coalesce(try(var.default_node_pool.enable_auto_scaling, null), false) ? (
      try(var.default_node_pool.min_count, null) != null &&
      try(var.default_node_pool.max_count, null) != null &&
      try(var.default_node_pool.min_count <= var.default_node_pool.max_count, false)
    ) : true
    error_message = "default_node_pool.min_count must be less than or equal to default_node_pool.max_count."
  }

  validation {
    condition = !coalesce(try(var.default_node_pool.enable_auto_scaling, null), false) ? true : (
      try(var.default_node_pool.min_count, 0) >= 1 &&
      try(var.default_node_pool.max_count, 0) >= 1
    )
    error_message = "default_node_pool.min_count and default_node_pool.max_count must both be at least 1 when enable_auto_scaling is true."
  }

  validation {
    condition = (
      try(var.default_node_pool.vnet_subnet_id, null) == null ||
      trimspace(try(var.default_node_pool.vnet_subnet_id, "")) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.default_node_pool.vnet_subnet_id))
    )
    error_message = "default_node_pool.vnet_subnet_id must be empty or a valid subnet resource ID."
  }

  validation {
    condition     = contains(["Ubuntu", "AzureLinux"], var.default_node_pool.os_sku)
    error_message = "default_node_pool.os_sku must be Ubuntu or AzureLinux."
  }

  validation {
    condition     = contains(["Managed", "Ephemeral"], var.default_node_pool.os_disk_type)
    error_message = "default_node_pool.os_disk_type must be Managed or Ephemeral."
  }

  validation {
    condition     = contains(["VirtualMachineScaleSets"], var.default_node_pool.type)
    error_message = "default_node_pool.type must be VirtualMachineScaleSets."
  }

  validation {
    condition = (
      try(var.default_node_pool.temporary_name_for_rotation, null) == null ||
      try(trimspace(var.default_node_pool.temporary_name_for_rotation), "") == "" ||
      can(regex("^[a-z0-9]{1,12}$", try(trimspace(var.default_node_pool.temporary_name_for_rotation), "")))
    )
    error_message = "default_node_pool.temporary_name_for_rotation must be empty or 1-12 lowercase alphanumeric characters."
  }
}

variable "network_profile" {
  description = "AKS network profile configuration."
  type = object({
    network_plugin      = optional(string, "azure")
    network_plugin_mode = optional(string)
    network_policy      = optional(string)
    service_cidr        = optional(string)
    dns_service_ip      = optional(string)
    pod_cidr            = optional(string)
    load_balancer_sku   = optional(string, "standard")
    outbound_type       = optional(string, "loadBalancer")
  })
  default = {}

  validation {
    condition     = contains(["azure", "kubenet", "none"], var.network_profile.network_plugin)
    error_message = "network_profile.network_plugin must be azure, kubenet, or none."
  }

  validation {
    condition = try(var.network_profile.network_plugin_mode, null) == null ? true : contains(
      ["overlay"],
      var.network_profile.network_plugin_mode
    )
    error_message = "network_profile.network_plugin_mode must be null or overlay."
  }

  validation {
    condition     = try(var.network_profile.network_plugin_mode, null) == null || var.network_profile.network_plugin == "azure"
    error_message = "network_profile.network_plugin_mode can only be set when network_profile.network_plugin is azure."
  }

  validation {
    condition = try(var.network_profile.network_policy, null) == null ? true : contains(
      ["azure", "calico", "cilium"],
      var.network_profile.network_policy
    )
    error_message = "network_profile.network_policy must be null, azure, calico, or cilium."
  }

  validation {
    condition     = contains(["standard"], lower(var.network_profile.load_balancer_sku))
    error_message = "network_profile.load_balancer_sku must be standard."
  }

  validation {
    condition     = contains(["loadBalancer", "managedNATGateway", "userDefinedRouting", "userAssignedNATGateway", "none", "block"], var.network_profile.outbound_type)
    error_message = "network_profile.outbound_type is invalid."
  }

  validation {
    condition = (
      (try(var.network_profile.service_cidr, null) == null && try(var.network_profile.dns_service_ip, null) == null) ||
      (try(var.network_profile.service_cidr, null) != null && try(var.network_profile.dns_service_ip, null) != null)
    )
    error_message = "network_profile.service_cidr and network_profile.dns_service_ip must either both be set or both be null."
  }

  validation {
    condition     = try(var.network_profile.service_cidr, null) == null || can(cidrhost(var.network_profile.service_cidr, 0))
    error_message = "network_profile.service_cidr must be null or a valid CIDR range."
  }

  validation {
    condition     = try(var.network_profile.pod_cidr, null) == null || can(cidrhost(var.network_profile.pod_cidr, 0))
    error_message = "network_profile.pod_cidr must be null or a valid CIDR range."
  }
}

variable "azure_policy_enabled" {
  type        = bool
  description = "Whether to enable the Azure Policy AKS add-on."
  default     = true
}

variable "image_cleaner_enabled" {
  type        = bool
  description = "Whether to enable the AKS image cleaner feature on cluster nodes."
  default     = true
}

variable "image_cleaner_interval_hours" {
  type        = number
  description = "Interval in hours for AKS image cleaner when enabled."
  default     = 48

  validation {
    condition     = var.image_cleaner_interval_hours >= 24 && var.image_cleaner_interval_hours <= 2160
    error_message = "image_cleaner_interval_hours must be between 24 and 2160 hours."
  }
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create a diagnostic setting for the AKS cluster."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID for diagnostics. Required when enable_diagnostics is true."
  default     = ""

  validation {
    condition     = !var.enable_diagnostics || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be a valid Log Analytics workspace resource ID when enable_diagnostics is true."
  }
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable for AKS."
  default     = []
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable for AKS."
  default     = ["AllMetrics"]
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the AKS resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "key_vault_secrets_provider_enabled" {
  type        = bool
  description = "Whether the Azure Key Vault secrets provider is enabled."
  default     = false
}

variable "key_vault_secrets_provider_secret_rotation_enabled" {
  type        = bool
  description = "Whether secret rotation is enabled for the Azure Key Vault secrets provider."
  default     = false
}

variable "key_vault_secrets_provider_secret_rotation_interval" {
  type        = string
  description = "The interval to check for secret changes. Only applies if key_vault_secrets_provider_secret_rotation_enabled is true."
  default     = "2m"
}

check "aks_input_consistency" {
  assert {
    condition     = !var.enable_diagnostics || trimspace(var.log_analytics_workspace_id) != ""
    error_message = "log_analytics_workspace_id must be set when enable_diagnostics is true."
  }

  assert {
    condition     = var.private_cluster_enabled || trimspace(var.private_dns_zone_id) == ""
    error_message = "private_dns_zone_id can only be set when private_cluster_enabled is true."
  }

  assert {
    condition     = var.private_cluster_enabled || trimspace(var.private_dns_zone_name) == ""
    error_message = "private_dns_zone_name can only be set when private_cluster_enabled is true."
  }

  assert {
    condition     = var.private_cluster_enabled || trimspace(var.private_dns_zone_resource_group_name) == ""
    error_message = "private_dns_zone_resource_group_name can only be set when private_cluster_enabled is true."
  }

  assert {
    condition     = var.private_cluster_enabled || !var.private_cluster_public_fqdn_enabled
    error_message = "private_cluster_public_fqdn_enabled can only be true when private_cluster_enabled is true."
  }

  assert {
    condition     = !var.private_cluster_enabled || length(var.api_server_authorized_ip_ranges) == 0
    error_message = "api_server_authorized_ip_ranges must be empty when private_cluster_enabled is true."
  }

  assert {
    condition     = var.private_cluster_enabled || length(var.api_server_authorized_ip_ranges) == 0 || var.network_profile.outbound_type != "none"
    error_message = "When api_server_authorized_ip_ranges is set on a public cluster, outbound networking must remain enabled."
  }

  assert {
    condition     = !var.private_cluster_enabled || trimspace(var.node_resource_group_name) == "" || lower(trimspace(var.node_resource_group_name)) != lower(trimspace(var.resource_group_name))
    error_message = "node_resource_group_name must be different from resource_group_name."
  }

  assert {
    condition = (
      try(var.network_profile.pod_cidr, null) == null ||
      contains(["kubenet"], var.network_profile.network_plugin) ||
      try(var.network_profile.network_plugin_mode, null) == "overlay"
    )
    error_message = "network_profile.pod_cidr is supported only with kubenet or Azure CNI overlay."
  }

  assert {
    condition = (
      !var.key_vault_secrets_provider_secret_rotation_enabled ||
      var.key_vault_secrets_provider_enabled
    )
    error_message = "key_vault_secrets_provider_secret_rotation_enabled can only be true when key_vault_secrets_provider_enabled is true."
  }

  assert {
    condition = (
      !var.key_vault_secrets_provider_secret_rotation_enabled ||
      trimspace(var.key_vault_secrets_provider_secret_rotation_interval) != ""
    )
    error_message = "key_vault_secrets_provider_secret_rotation_interval must be non-empty when secret rotation is enabled."
  }

  assert {
    condition = (
      !var.image_cleaner_enabled ||
      var.image_cleaner_interval_hours >= 24
    )
    error_message = "image_cleaner_interval_hours must be at least 24 when image cleaner is enabled."
  }
}
