variable "name" {
  description = "Optional Flex Consumption Function App name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[a-z0-9][a-z0-9-]{0,30}[a-z0-9]$", trimspace(var.name)))
    error_message = "name must be empty or 2-32 lowercase characters, numbers, or hyphens, starting and ending with a letter or number."
  }
}

variable "name_prefix" {
  description = "Prefix used when the Flex Consumption Function App name is generated."
  type        = string
  default     = "func"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,15}$", trimspace(var.name_prefix)))
    error_message = "name_prefix must be 1-15 lowercase letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group where the Flex Consumption Function App is deployed."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Flex Consumption Function App. Leave empty to use the existing resource group's location."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "location_code" {
  description = "Optional short location code used when the Function App name is generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location_code) == "" || can(regex("^[a-z0-9-]{2,20}$", trimspace(var.location_code)))
    error_message = "location_code must be empty or 2-20 lowercase letters, numbers, or hyphens."
  }
}

variable "workload_name" {
  description = "Optional workload segment used when the Function App name is generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.workload_name) == "" || can(regex("^[a-z0-9-]{1,30}$", trimspace(var.workload_name)))
    error_message = "workload_name must be empty or 1-30 lowercase letters, numbers, or hyphens."
  }
}

variable "workload" {
  description = "Compatibility workload segment used when workload_name is empty."
  type        = string
  default     = "project"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,30}$", trimspace(var.workload)))
    error_message = "workload must be 1-30 lowercase letters, numbers, or hyphens."
  }
}

variable "app_env" {
  description = "Deployment environment used when the Function App name is generated."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa", "poc"], var.app_env)
    error_message = "app_env must be one of: dev, staging, prod, sbx, test, qa, poc."
  }
}

variable "instance" {
  description = "Instance identifier used when the Function App name is generated."
  type        = string
  default     = "001"

  validation {
    condition     = can(regex("^[a-z0-9-]{1,10}$", trimspace(var.instance)))
    error_message = "instance must be 1-10 lowercase letters, numbers, or hyphens."
  }
}

variable "service_plan_id" {
  description = "Resource ID of an existing Flex Consumption App Service Plan. The plan must use the FC1 SKU and Linux operating system."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Web/serverFarms/.+$", trimspace(var.service_plan_id)))
    error_message = "service_plan_id must be a valid App Service Plan resource ID."
  }
}

variable "runtime_name" {
  description = "Flex Consumption runtime name."
  type        = string

  validation {
    condition     = contains(["node", "dotnet-isolated", "powershell", "python", "java", "custom"], var.runtime_name)
    error_message = "runtime_name must be node, dotnet-isolated, powershell, python, java, or custom."
  }
}

variable "runtime_version" {
  description = "Version supported by runtime_name, such as 20 for Node.js, 3.11 for Python, or 8.0 for .NET isolated."
  type        = string

  validation {
    condition     = trimspace(var.runtime_version) != ""
    error_message = "runtime_version cannot be empty."
  }
}

variable "storage_container_type" {
  description = "Flex deployment storage container type. Azure currently supports blobContainer."
  type        = string
  default     = "blobContainer"

  validation {
    condition     = var.storage_container_type == "blobContainer"
    error_message = "storage_container_type must be blobContainer."
  }
}

variable "storage_container_endpoint" {
  description = "Endpoint or resource ID of the blob container where the Function App package is hosted."
  type        = string

  validation {
    condition     = trimspace(var.storage_container_endpoint) != ""
    error_message = "storage_container_endpoint cannot be empty."
  }
}

variable "storage_authentication_type" {
  description = "Authentication method used by the Flex Function App to access deployment storage."
  type        = string
  default     = "StorageAccountConnectionString"

  validation {
    condition     = contains(["StorageAccountConnectionString", "UserAssignedIdentity"], var.storage_authentication_type)
    error_message = "storage_authentication_type must be StorageAccountConnectionString or UserAssignedIdentity."
  }
}

variable "storage_access_key" {
  description = "Storage account access key used when storage_authentication_type is StorageAccountConnectionString."
  type        = string
  default     = null
  sensitive   = true
}

variable "storage_user_assigned_identity_id" {
  description = "User-assigned managed identity resource ID used when storage_authentication_type is UserAssignedIdentity."
  type        = string
  default     = null

  validation {
    condition     = var.storage_user_assigned_identity_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.+$", var.storage_user_assigned_identity_id))
    error_message = "storage_user_assigned_identity_id must be null or a valid user-assigned managed identity resource ID."
  }
}

variable "instance_memory_in_mb" {
  description = "Memory allocated to each Flex Consumption instance. Azure currently supports 2048 or 4096 MB."
  type        = number
  default     = 2048

  validation {
    condition     = contains([2048, 4096], var.instance_memory_in_mb)
    error_message = "instance_memory_in_mb must be 2048 or 4096."
  }
}

variable "maximum_instance_count" {
  description = "Maximum number of Flex Consumption instances. Leave null to use the platform default."
  type        = number
  default     = null

  validation {
    condition     = var.maximum_instance_count == null || (var.maximum_instance_count >= 1 && var.maximum_instance_count <= 1000)
    error_message = "maximum_instance_count must be null or between 1 and 1000."
  }
}

variable "http_concurrency" {
  description = "Maximum HTTP concurrency per Flex Consumption instance. Leave null for platform assignment."
  type        = number
  default     = null

  validation {
    condition     = var.http_concurrency == null || (var.http_concurrency >= 1 && var.http_concurrency <= 1000)
    error_message = "http_concurrency must be null or between 1 and 1000."
  }
}

variable "always_ready" {
  description = "Map of Flex function names to always-ready instance counts."
  type        = map(number)
  default     = {}

  validation {
    condition     = alltrue([for name, count in var.always_ready : trimspace(name) != "" && count >= 0])
    error_message = "always_ready names must be non-empty and instance counts must be zero or greater."
  }
}

variable "enabled" {
  description = "Whether the Flex Consumption Function App is enabled."
  type        = bool
  default     = true
}

variable "https_only" {
  description = "Whether only HTTPS traffic is allowed."
  type        = bool
  default     = true
}

variable "public_network_access_enabled" {
  description = "Whether public network access is enabled."
  type        = bool
  default     = false
}

variable "client_certificate_enabled" {
  description = "Whether client certificates are enabled for inbound requests."
  type        = bool
  default     = false
}

variable "client_certificate_mode" {
  description = "Client certificate mode when client certificates are enabled."
  type        = string
  default     = "Optional"

  validation {
    condition     = contains(["Required", "Optional", "OptionalInteractiveUser"], var.client_certificate_mode)
    error_message = "client_certificate_mode must be Required, Optional, or OptionalInteractiveUser."
  }
}

variable "client_certificate_exclusion_paths" {
  description = "Paths excluded from client certificate authentication, separated by semicolons."
  type        = string
  default     = null
}

variable "webdeploy_publish_basic_authentication_enabled" {
  description = "Whether WebDeploy publishing basic authentication is enabled."
  type        = bool
  default     = false
}

variable "virtual_network_subnet_id" {
  description = "Optional subnet ID used for regional VNet integration."
  type        = string
  default     = null
}

variable "app_settings" {
  description = "Application settings for the Flex Consumption Function App."
  type        = map(string)
  default     = {}
  sensitive   = true
}

variable "zip_deploy_file" {
  description = "Optional local ZIP package path for deployment. The caller must set the required package app settings."
  type        = string
  default     = null
}

variable "app_command_line" {
  description = "Optional command line used to launch the application."
  type        = string
  default     = null
}

variable "application_insights_connection_string" {
  description = "Optional Application Insights connection string."
  type        = string
  default     = null
  sensitive   = true
}

variable "application_insights_key" {
  description = "Optional Application Insights instrumentation key."
  type        = string
  default     = null
  sensitive   = true
}

variable "default_documents" {
  description = "Optional default documents for the Function App site."
  type        = list(string)
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "Minutes before an unhealthy node is removed from the load balancer when health_check_path is set."
  type        = number
  default     = null
}

variable "health_check_path" {
  description = "Optional health check path for the Function App."
  type        = string
  default     = null
}

variable "http2_enabled" {
  description = "Whether HTTP/2 is enabled."
  type        = bool
  default     = false
}

variable "minimum_tls_version" {
  description = "Minimum TLS version for inbound SSL requests."
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.2", "1.3"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.2 or 1.3."
  }
}

variable "runtime_scale_monitoring_enabled" {
  description = "Whether Functions runtime scale monitoring is enabled."
  type        = bool
  default     = false
}

variable "scm_minimum_tls_version" {
  description = "Minimum TLS version for the SCM site."
  type        = string
  default     = "1.2"

  validation {
    condition     = contains(["1.2", "1.3"], var.scm_minimum_tls_version)
    error_message = "scm_minimum_tls_version must be 1.2 or 1.3."
  }
}

variable "use_32_bit_worker" {
  description = "Whether the Function App should use a 32-bit worker."
  type        = bool
  default     = false
}

variable "vnet_route_all_enabled" {
  description = "Whether all outbound traffic should route through the integrated VNet."
  type        = bool
  default     = false
}

variable "websockets_enabled" {
  description = "Whether WebSockets are enabled."
  type        = bool
  default     = false
}

variable "identity_type" {
  description = "Optional managed identity type for the Function App."
  type        = string
  default     = null

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "identity_type must be null, SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "identity_ids" {
  description = "User-assigned managed identity resource IDs assigned to the Function App."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for identity_id in var.identity_ids : can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.ManagedIdentity/userAssignedIdentities/.+$", identity_id))])
    error_message = "identity_ids must contain valid user-assigned managed identity resource IDs."
  }
}

variable "inherit_resource_group_tags" {
  description = "Whether to merge tags from the target resource group into the Function App."
  type        = bool
  default     = true
}

variable "inherited_resource_group_tags" {
  description = "Optional plan-known resource group tags. When null and inheritance is enabled, the module reads the resource group."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags applied to the Function App. Caller tags override inherited resource-group tags."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for key, value in var.tags : trimspace(key) != "" && trimspace(value) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

variable "timeouts" {
  description = "Optional timeouts for Function App create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
