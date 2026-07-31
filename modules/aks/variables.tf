variable "resource_group_name" {
  type        = string
  description = "The name of the resource group where the AKS cluster will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into AKS resources. The module only reads the resource group when this is true or location is empty."
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

variable "location" {
  type        = string
  description = "The Azure region where to deploy the AKS cluster. If empty, the resource group's location is used."
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "AKS cluster name. Leave empty to auto-generate a standardized name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 1 &&
      length(trimspace(var.name)) <= 63 &&
      can(regex("^[A-Za-z0-9][A-Za-z0-9-_]{0,62}$", trimspace(var.name)))
    )
    error_message = "name must be empty or 1-63 characters and contain only letters, numbers, hyphens, or underscores."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the AKS cluster name is generated."
  default     = "aks"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using lowercase letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the AKS cluster name is generated."
  default     = ""

  validation {
    condition     = var.workload_name == "" || can(regex("^[a-z0-9-]{1,35}$", var.workload_name))
    error_message = "workload_name must be empty or 1-35 characters using lowercase letters, digits, or hyphens."
  }
}

variable "app_env" {
  description = "Deployment environment used for standard tags and generated naming."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev", "sbx", "test", "qa", "poc"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, sbx, test, qa, poc."
  }
}

variable "include_environment_in_name" {
  type        = bool
  description = "Whether generated AKS names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the AKS cluster name is generated."
  default     = ""

  validation {
    condition     = var.location_code == "" || can(regex("^[a-z0-9-]{2,20}$", var.location_code))
    error_message = "location_code must be empty or 2-20 lowercase letters, digits, or hyphens."
  }
}

variable "instance" {
  type        = string
  description = "Optional instance segment used when generated names do not use a random suffix."
  default     = "001"

  validation {
    condition     = var.instance == "" || can(regex("^[a-z0-9-]{1,10}$", var.instance))
    error_message = "instance must be empty or 1-10 lowercase letters, digits, or hyphens."
  }
}

variable "use_random_suffix" {
  type        = bool
  description = "Whether generated AKS names should include a random suffix."
  default     = true
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

variable "dns_prefix" {
  type        = string
  description = "Optional DNS prefix for the AKS API server. If empty, the module derives one from the cluster name."
  default     = ""

  validation {
    condition = var.dns_prefix == "" || (
      length(var.dns_prefix) <= 54 &&
      can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.dns_prefix))
    )
    error_message = "dns_prefix must be empty or 1-54 lowercase alphanumeric or hyphen characters, and start and end with an alphanumeric character."
  }
}

variable "dns_prefix_private_cluster" {
  type        = string
  description = "Optional DNS prefix for private AKS clusters. When set, dns_prefix is not used."
  default     = ""

  validation {
    condition = var.dns_prefix_private_cluster == "" || (
      length(var.dns_prefix_private_cluster) <= 54 &&
      can(regex("^[a-z0-9]([a-z0-9-]*[a-z0-9])?$", var.dns_prefix_private_cluster))
    )
    error_message = "dns_prefix_private_cluster must be empty or 1-54 lowercase alphanumeric or hyphen characters, and start and end with an alphanumeric character."
  }
}

variable "kubernetes_version" {
  type        = string
  description = "Optional Kubernetes version for the AKS control plane. Leave null to let AKS choose the default supported version."
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

variable "support_plan" {
  type        = string
  description = "AKS support plan."
  default     = "KubernetesOfficial"

  validation {
    condition     = contains(["KubernetesOfficial", "AKSLongTermSupport"], var.support_plan)
    error_message = "support_plan must be KubernetesOfficial or AKSLongTermSupport."
  }
}

variable "cost_analysis_enabled" {
  type        = bool
  description = "Whether AKS cost analysis is enabled. Requires sku_tier Standard or Premium."
  default     = false
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
  description = "Optional private DNS zone resource ID for a private AKS cluster. Use System for AKS-managed DNS or None for custom DNS."
  default     = ""

  validation {
    condition = (
      trimspace(var.private_dns_zone_id) == "" ||
      contains(["System", "None"], trimspace(var.private_dns_zone_id)) ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    )
    error_message = "private_dns_zone_id must be empty, System, None, or a valid Private DNS zone resource ID."
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

variable "admin_group_object_ids" {
  type        = list(string)
  description = "Additional Microsoft Entra group object IDs configured as AKS administrator groups."
  default     = []

  validation {
    condition = alltrue([
      for value in var.admin_group_object_ids :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", value))
    ])
    error_message = "admin_group_object_ids must contain valid Microsoft Entra object IDs."
  }
}

variable "tenant_id" {
  type        = string
  description = "Optional Microsoft Entra tenant ID for AKS Azure AD RBAC. Leave empty to let AzureRM use the current tenant."
  default     = ""

  validation {
    condition = (
      trimspace(var.tenant_id) == "" ||
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", var.tenant_id))
    )
    error_message = "tenant_id must be empty or a valid UUID."
  }
}

variable "local_account_disabled" {
  type        = bool
  description = "Whether local AKS admin accounts are disabled."
  default     = true
}

variable "run_command_enabled" {
  type        = bool
  description = "Whether AKS run command is enabled."
  default     = true
}

variable "api_server_access_profile" {
  description = "Optional AKS API server access profile. Use subnet_id and virtual_network_integration_enabled for API Server VNet Integration."
  type = object({
    authorized_ip_ranges                = optional(list(string), [])
    subnet_id                           = optional(string)
    virtual_network_integration_enabled = optional(bool, false)
  })
  default = null
}

variable "api_server_authorized_ip_ranges" {
  type        = list(string)
  description = "Backward-compatible shortcut for CIDR ranges allowed to reach the AKS API server when the cluster is public."
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

variable "identity_ids" {
  type        = list(string)
  description = "Optional user-assigned managed identity IDs for the AKS control plane. When empty, a system-assigned identity is used."
  default     = []

  validation {
    condition = alltrue([
      for value in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", value))
    ])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "kubelet_identity" {
  description = "Optional kubelet user-assigned identity configuration."
  type = object({
    client_id                 = string
    object_id                 = string
    user_assigned_identity_id = string
  })
  default = null
}

variable "app_admin_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive AKS admin treatment."
  default     = []

  validation {
    condition     = alltrue([for value in var.app_admin_group : trimspace(value) != ""])
    error_message = "app_admin_group values must not be empty."
  }
}

variable "app_user_group" {
  type        = list(string)
  description = "List of Microsoft Entra group display names or object IDs that should receive reader access on the AKS cluster resource."
  default     = []

  validation {
    condition     = alltrue([for value in var.app_user_group : trimspace(value) != ""])
    error_message = "app_user_group values must not be empty."
  }
}

variable "app_admin_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_admin_group principals at the AKS cluster scope."
  default     = "Contributor"
}

variable "app_user_role_definition_name" {
  type        = string
  description = "Azure role assigned to app_user_group principals at the AKS cluster scope."
  default     = "Reader"
}

variable "terraform_execution_aks_role" {
  type        = string
  description = "Optional Azure Kubernetes Service RBAC role to assign to the current Terraform execution identity on the AKS cluster."
  default     = ""

  validation {
    condition = contains([
      "",
      "Azure Kubernetes Service RBAC Cluster Admin",
      "Azure Kubernetes Service RBAC Cluster Writer",
      "Azure Kubernetes Service RBAC Writer",
      "Azure Kubernetes Service RBAC Viewer"
    ], var.terraform_execution_aks_role)
    error_message = "terraform_execution_aks_role must be empty or a valid Azure Kubernetes Service RBAC role supported by this module."
  }
}

variable "role_assignments" {
  description = "Additional role assignments scoped to the AKS cluster."
  type = map(object({
    principal_id                           = string
    principal_type                         = optional(string)
    role_definition_name                   = optional(string)
    role_definition_id                     = optional(string)
    name                                   = optional(string)
    description                            = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for _, assignment in var.role_assignments :
      (
        try(trimspace(assignment.role_definition_name), "") != "" &&
        try(trimspace(assignment.role_definition_id), "") == ""
        ) || (
        try(trimspace(assignment.role_definition_name), "") == "" &&
        try(trimspace(assignment.role_definition_id), "") != ""
      )
    ])
    error_message = "Each role_assignments item must specify exactly one of role_definition_name or role_definition_id."
  }
}

variable "default_node_pool" {
  description = "Default system node pool configuration."
  type = object({
    name                          = optional(string, "system")
    vm_size                       = optional(string, "Standard_D4s_v5")
    node_count                    = optional(number, 1)
    enable_auto_scaling           = optional(bool)
    auto_scaling_enabled          = optional(bool)
    min_count                     = optional(number)
    max_count                     = optional(number)
    zones                         = optional(list(string), [])
    os_disk_size_gb               = optional(number, 128)
    os_disk_type                  = optional(string, "Managed")
    os_sku                        = optional(string, "Ubuntu")
    max_pods                      = optional(number)
    vnet_subnet_id                = optional(string)
    pod_subnet_id                 = optional(string)
    only_critical_addons_enabled  = optional(bool, false)
    orchestrator_version          = optional(string)
    type                          = optional(string, "VirtualMachineScaleSets")
    temporary_name_for_rotation   = optional(string)
    host_encryption_enabled       = optional(bool, false)
    ultra_ssd_enabled             = optional(bool, false)
    fips_enabled                  = optional(bool, false)
    kubelet_disk_type             = optional(string)
    node_labels                   = optional(map(string), {})
    node_public_ip_enabled        = optional(bool, false)
    node_public_ip_prefix_id      = optional(string)
    capacity_reservation_group_id = optional(string)
    host_group_id                 = optional(string)
    proximity_placement_group_id  = optional(string)
    scale_down_mode               = optional(string)
    snapshot_id                   = optional(string)
    tags                          = optional(map(string), {})
    workload_runtime              = optional(string)
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_files   = optional(number)
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }))
    linux_os_config = optional(object({
      swap_file_size_mb             = optional(number)
      transparent_huge_page         = optional(string)
      transparent_huge_page_defrag  = optional(string)
      transparent_huge_page_enabled = optional(string)
    }))
    node_network_profile = optional(object({
      application_security_group_ids = optional(list(string), [])
      node_public_ip_tags            = optional(map(string), {})
      allowed_host_ports = optional(list(object({
        port_start = optional(number)
        port_end   = optional(number)
        protocol   = optional(string)
      })), [])
    }))
    upgrade_settings = optional(object({
      max_surge                     = optional(string)
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    }))
  })
  default = {}

  validation {
    condition     = can(regex("^[a-z0-9]{1,12}$", var.default_node_pool.name))
    error_message = "default_node_pool.name must be 1-12 lowercase alphanumeric characters."
  }

  validation {
    condition     = try(var.default_node_pool.node_count >= 1, true)
    error_message = "default_node_pool.node_count must be at least 1."
  }

  validation {
    condition = try(coalesce(var.default_node_pool.auto_scaling_enabled, var.default_node_pool.enable_auto_scaling), false) ? (
      try(var.default_node_pool.min_count, null) != null &&
      try(var.default_node_pool.max_count, null) != null &&
      try(var.default_node_pool.min_count <= var.default_node_pool.max_count, false)
    ) : true
    error_message = "default_node_pool.min_count and default_node_pool.max_count are required when autoscaling is enabled, and min_count must be less than or equal to max_count."
  }

  validation {
    condition = (
      try(var.default_node_pool.vnet_subnet_id, null) == null ||
      try(trimspace(var.default_node_pool.vnet_subnet_id), "") == "" ||
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
}

variable "node_pools" {
  description = "Additional AKS node pools keyed by Terraform map key."
  type = map(object({
    name                          = optional(string)
    vm_size                       = string
    mode                          = optional(string, "User")
    os_type                       = optional(string, "Linux")
    os_sku                        = optional(string)
    node_count                    = optional(number)
    auto_scaling_enabled          = optional(bool, true)
    min_count                     = optional(number)
    max_count                     = optional(number)
    zones                         = optional(list(string), [])
    orchestrator_version          = optional(string)
    max_pods                      = optional(number)
    vnet_subnet_id                = optional(string)
    pod_subnet_id                 = optional(string)
    os_disk_size_gb               = optional(number)
    os_disk_type                  = optional(string)
    kubelet_disk_type             = optional(string)
    node_labels                   = optional(map(string), {})
    node_taints                   = optional(list(string), [])
    node_public_ip_enabled        = optional(bool, false)
    node_public_ip_prefix_id      = optional(string)
    priority                      = optional(string)
    eviction_policy               = optional(string)
    spot_max_price                = optional(number)
    scale_down_mode               = optional(string)
    temporary_name_for_rotation   = optional(string)
    ultra_ssd_enabled             = optional(bool, false)
    host_encryption_enabled       = optional(bool, false)
    fips_enabled                  = optional(bool, false)
    capacity_reservation_group_id = optional(string)
    host_group_id                 = optional(string)
    proximity_placement_group_id  = optional(string)
    snapshot_id                   = optional(string)
    workload_runtime              = optional(string)
    gpu_driver                    = optional(string)
    gpu_instance                  = optional(string)
    tags                          = optional(map(string), {})
    kubelet_config = optional(object({
      allowed_unsafe_sysctls    = optional(list(string))
      container_log_max_files   = optional(number)
      container_log_max_line    = optional(number)
      container_log_max_size_mb = optional(number)
      cpu_cfs_quota_enabled     = optional(bool)
      cpu_cfs_quota_period      = optional(string)
      cpu_manager_policy        = optional(string)
      image_gc_high_threshold   = optional(number)
      image_gc_low_threshold    = optional(number)
      pod_max_pid               = optional(number)
      topology_manager_policy   = optional(string)
    }))
    linux_os_config = optional(object({
      swap_file_size_mb             = optional(number)
      transparent_huge_page         = optional(string)
      transparent_huge_page_defrag  = optional(string)
      transparent_huge_page_enabled = optional(string)
    }))
    node_network_profile = optional(object({
      application_security_group_ids = optional(list(string), [])
      node_public_ip_tags            = optional(map(string), {})
      allowed_host_ports = optional(list(object({
        port_start = optional(number)
        port_end   = optional(number)
        protocol   = optional(string)
      })), [])
    }))
    upgrade_settings = optional(object({
      max_surge                     = optional(string)
      max_unavailable               = optional(string)
      drain_timeout_in_minutes      = optional(number)
      node_soak_duration_in_minutes = optional(number)
      undrainable_node_behavior     = optional(string)
    }))
    windows_profile = optional(object({
      outbound_nat_enabled = optional(bool)
    }))
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false
}

variable "network_profile" {
  description = "AKS network profile configuration."
  type = object({
    network_plugin      = optional(string, "azure")
    network_plugin_mode = optional(string, "overlay")
    network_policy      = optional(string, "cilium")
    network_data_plane  = optional(string, "cilium")
    network_mode        = optional(string)
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    dns_service_ip      = optional(string)
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    ip_versions         = optional(list(string), ["IPv4"])
    load_balancer_sku   = optional(string, "standard")
    outbound_type       = optional(string, "loadBalancer")
    load_balancer_profile = optional(object({
      backend_pool_type           = optional(string)
      idle_timeout_in_minutes     = optional(number)
      managed_outbound_ip_count   = optional(number)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_address_ids     = optional(list(string))
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ports_allocated    = optional(number)
    }))
    nat_gateway_profile = optional(object({
      idle_timeout_in_minutes   = optional(number)
      managed_outbound_ip_count = optional(number)
    }))
    advanced_networking = optional(object({
      observability_enabled = optional(bool)
      security_enabled      = optional(bool)
    }))
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
    condition     = try(var.network_profile.network_data_plane, null) == null || contains(["azure", "cilium"], var.network_profile.network_data_plane)
    error_message = "network_profile.network_data_plane must be null, azure, or cilium."
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
}

variable "auto_scaler_profile" {
  description = "Optional cluster autoscaler profile."
  type = object({
    balance_similar_node_groups                   = optional(bool)
    daemonset_eviction_for_empty_nodes_enabled    = optional(bool)
    daemonset_eviction_for_occupied_nodes_enabled = optional(bool)
    empty_bulk_delete_max                         = optional(string)
    expander                                      = optional(string)
    ignore_daemonsets_utilization_enabled         = optional(bool)
    max_graceful_termination_sec                  = optional(string)
    max_node_provisioning_time                    = optional(string)
    max_unready_nodes                             = optional(number)
    max_unready_percentage                        = optional(number)
    new_pod_scale_up_delay                        = optional(string)
    scale_down_delay_after_add                    = optional(string)
    scale_down_delay_after_delete                 = optional(string)
    scale_down_delay_after_failure                = optional(string)
    scale_down_unneeded                           = optional(string)
    scale_down_unready                            = optional(string)
    scale_down_utilization_threshold              = optional(string)
    scan_interval                                 = optional(string)
    skip_nodes_with_local_storage                 = optional(bool)
    skip_nodes_with_system_pods                   = optional(bool)
  })
  default = null
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

variable "oms_agent_enabled" {
  type        = bool
  description = "Whether to enable the Container Insights OMS agent. Also enabled automatically when oms_agent_log_analytics_workspace_id is supplied."
  default     = false
}

variable "oms_agent_log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for Container Insights."
  default     = ""
}

variable "oms_agent_msi_auth_for_monitoring_enabled" {
  type        = bool
  description = "Whether OMS agent uses managed identity authentication."
  default     = true
}

variable "microsoft_defender_enabled" {
  type        = bool
  description = "Whether Microsoft Defender for Containers profile is enabled. Also enabled automatically when microsoft_defender_log_analytics_workspace_id is supplied."
  default     = false
}

variable "microsoft_defender_log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace ID for Microsoft Defender for Containers."
  default     = ""
}

variable "monitor_metrics_enabled" {
  type        = bool
  description = "Whether the managed Prometheus monitor metrics profile is enabled."
  default     = false
}

variable "monitor_metrics" {
  description = "Managed Prometheus monitor metrics allow-lists."
  type = object({
    annotations_allowed = optional(string)
    labels_allowed      = optional(string)
  })
  default = null
}

variable "storage_profile" {
  description = "AKS storage CSI driver profile."
  type = object({
    blob_driver_enabled         = optional(bool, false)
    disk_driver_enabled         = optional(bool, true)
    file_driver_enabled         = optional(bool, true)
    snapshot_controller_enabled = optional(bool, true)
  })
  default = null
}

variable "workload_autoscaler_profile" {
  description = "Optional workload autoscaler profile."
  type = object({
    keda_enabled                    = optional(bool, false)
    vertical_pod_autoscaler_enabled = optional(bool, false)
  })
  default = null
}

variable "key_vault_secrets_provider_enabled" {
  type        = bool
  description = "Whether the Azure Key Vault Secrets Store CSI driver is enabled."
  default     = false
}

variable "key_vault_secrets_provider_secret_rotation_enabled" {
  type        = bool
  description = "Whether secret rotation is enabled for the Azure Key Vault Secrets Store CSI driver."
  default     = false
}

variable "key_vault_secrets_provider_secret_rotation_interval" {
  type        = string
  description = "The interval to check for secret changes. Only applies if key_vault_secrets_provider_secret_rotation_enabled is true."
  default     = "2m"
}

variable "key_management_service" {
  description = "Optional KMS etcd encryption configuration."
  type = object({
    key_vault_key_id         = string
    key_vault_network_access = optional(string)
  })
  default = null
}

variable "ingress_application_gateway" {
  description = "Optional Application Gateway ingress controller add-on configuration."
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })
  default = null
}

variable "web_app_routing" {
  description = "Optional Web App Routing add-on configuration."
  type = object({
    dns_zone_ids             = list(string)
    default_nginx_controller = optional(string)
  })
  default = null
}

variable "http_proxy_config" {
  description = "Optional HTTP proxy configuration."
  type = object({
    http_proxy  = optional(string)
    https_proxy = optional(string)
    no_proxy    = optional(list(string))
    trusted_ca  = optional(string)
  })
  default = null
}

variable "linux_profile" {
  description = "Optional Linux profile for SSH access."
  type = object({
    admin_username = string
    ssh_key = object({
      key_data = string
    })
  })
  default = null
}

variable "windows_profile" {
  description = "Optional Windows profile required for Windows node pools."
  type = object({
    admin_username = string
    admin_password = string
    license        = optional(string)
  })
  default   = null
  sensitive = true
}

variable "maintenance_window" {
  description = "Optional allowed and not-allowed cluster maintenance windows."
  type = object({
    allowed = optional(list(object({
      day   = string
      hours = list(number)
    })), [])
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
}

variable "maintenance_window_auto_upgrade" {
  description = "Optional maintenance window for cluster auto-upgrades."
  type = object({
    frequency    = string
    interval     = number
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    start_date   = optional(string)
    utc_offset   = optional(string)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
}

variable "maintenance_window_node_os" {
  description = "Optional maintenance window for node OS image upgrades."
  type = object({
    frequency    = string
    interval     = number
    duration     = number
    day_of_week  = optional(string)
    day_of_month = optional(number)
    week_index   = optional(string)
    start_time   = optional(string)
    start_date   = optional(string)
    utc_offset   = optional(string)
    not_allowed = optional(list(object({
      start = string
      end   = string
    })), [])
  })
  default = null
}

variable "upgrade_override" {
  description = "Optional force-upgrade override."
  type = object({
    force_upgrade_enabled = bool
    effective_until       = optional(string)
  })
  default = null
}

variable "timeouts" {
  description = "Optional AKS cluster operation timeouts."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create a diagnostic setting for the AKS cluster. Diagnostics are also enabled automatically when any diagnostic destination ID is supplied."
  default     = false
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. Defaults to <aks-name>-diagnostic-setting."
  default     = ""
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Log Analytics workspace resource ID for diagnostics and optional add-ons."
  default     = ""

  validation {
    condition = (
      trimspace(var.log_analytics_workspace_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    )
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "log_analytics_destination_type" {
  type        = string
  description = "Diagnostic Log Analytics destination type."
  default     = null

  validation {
    condition     = try(contains(["AzureDiagnostics", "Dedicated"], var.log_analytics_destination_type), true)
    error_message = "log_analytics_destination_type must be null, AzureDiagnostics, or Dedicated."
  }
}

variable "diagnostic_storage_account_id" {
  type        = string
  description = "Optional Storage Account ID used to archive diagnostics."
  default     = ""

  validation {
    condition = (
      trimspace(var.diagnostic_storage_account_id) == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Storage/storageAccounts/.+$", var.diagnostic_storage_account_id))
    )
    error_message = "diagnostic_storage_account_id must be empty or a valid storage account resource ID."
  }
}

variable "diagnostic_eventhub_authorization_rule_id" {
  type        = string
  description = "Optional Event Hub authorization rule ID used to stream diagnostics."
  default     = ""
}

variable "diagnostic_eventhub_name" {
  type        = string
  description = "Optional Event Hub name used to stream diagnostics."
  default     = null
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable for AKS. Use AllLogs to emit the provider category group instead of individual categories."
  default     = ["AllLogs"]
}

variable "diagnostic_log_category_groups" {
  type        = list(string)
  description = "Diagnostic log category groups to enable, for example allLogs or audit."
  default     = []
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable for AKS."
  default     = ["AllMetrics"]
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to AKS resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "aks_input_consistency" {
  assert {
    condition = !(
      try(var.default_node_pool.auto_scaling_enabled, null) != null &&
      try(var.default_node_pool.enable_auto_scaling, null) != null &&
      var.default_node_pool.auto_scaling_enabled != var.default_node_pool.enable_auto_scaling
    )
    error_message = "default_node_pool.auto_scaling_enabled and the deprecated enable_auto_scaling alias cannot conflict."
  }

  assert {
    condition     = !var.cost_analysis_enabled || contains(["Standard", "Premium"], var.sku_tier)
    error_message = "cost_analysis_enabled requires sku_tier Standard or Premium."
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
    condition     = var.private_cluster_enabled || !var.private_cluster_public_fqdn_enabled
    error_message = "private_cluster_public_fqdn_enabled can only be true when private_cluster_enabled is true."
  }

  assert {
    condition     = !var.private_cluster_enabled || length(var.api_server_authorized_ip_ranges) == 0
    error_message = "api_server_authorized_ip_ranges must be empty when private_cluster_enabled is true. Use api_server_access_profile for API Server VNet Integration."
  }

  assert {
    condition     = trimspace(var.node_resource_group_name) == "" || lower(trimspace(var.node_resource_group_name)) != lower(trimspace(var.resource_group_name))
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
    condition     = var.network_profile.network_plugin != "kubenet" || var.network_profile.network_plugin_mode == null
    error_message = "kubenet cannot be used with network_plugin_mode."
  }

  assert {
    condition     = !var.key_vault_secrets_provider_secret_rotation_enabled || var.key_vault_secrets_provider_enabled
    error_message = "key_vault_secrets_provider_secret_rotation_enabled can only be true when key_vault_secrets_provider_enabled is true."
  }

  assert {
    condition     = !var.oms_agent_enabled || trimspace(local.oms_agent_workspace_id) != ""
    error_message = "oms_agent_enabled requires oms_agent_log_analytics_workspace_id or log_analytics_workspace_id."
  }

  assert {
    condition     = !var.microsoft_defender_enabled || trimspace(local.defender_workspace_id) != ""
    error_message = "microsoft_defender_enabled requires microsoft_defender_log_analytics_workspace_id or log_analytics_workspace_id."
  }

  assert {
    condition     = !var.enable_diagnostics || local.diagnostic_destination_enabled
    error_message = "enable_diagnostics requires at least one diagnostic destination: log_analytics_workspace_id, diagnostic_storage_account_id, or diagnostic_eventhub_authorization_rule_id."
  }
}
