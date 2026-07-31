variable "name" {
  description = "Optional Container App name override. Leave empty to generate one from the naming convention."
  type        = string
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 2 &&
      length(trimspace(var.name)) <= 32 &&
      can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", trimspace(var.name)))
    )
    error_message = "name must be empty or 2-32 lowercase letters, numbers, and hyphens, starting with a letter and ending with a letter or number."
  }
}

variable "resource_group_name" {
  description = "Resource group where the Container App will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region for the Container App. Leave empty to use the resource group location."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location) == "" || can(regex("^[a-z0-9-]+$", trimspace(var.location)))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into Container App resources."
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
  description = "Workload identifier used when name is not provided."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  type        = string
  default     = "dev"
  description = "Deployment environment used when name is not provided."

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "poc", "test"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, poc, test."
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

variable "location_code" {
  type        = string
  description = "Optional short location code used when name is not provided. Leave empty to derive it from location."
  default     = ""

  validation {
    condition     = trimspace(var.location_code) == "" || can(regex("^[a-z0-9-]{2,20}$", trimspace(var.location_code)))
    error_message = "location_code must be empty or 2-20 lowercase letters, numbers, or hyphens."
  }
}

variable "container_app_environment_id" {
  description = "Existing Azure Container Apps managed environment resource ID."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.App/managedEnvironments/.+$", trimspace(var.container_app_environment_id)))
    error_message = "container_app_environment_id must be a valid Microsoft.App/managedEnvironments resource ID."
  }
}

variable "revision_mode" {
  description = "Container App revision mode. Use Single for most apps, Multiple for blue/green or canary traffic splitting."
  type        = string
  default     = "Single"

  validation {
    condition     = contains(["Single", "Multiple"], var.revision_mode)
    error_message = "revision_mode must be Single or Multiple."
  }
}

variable "workload_profile_name" {
  description = "Optional workload profile name in the Container Apps environment."
  type        = string
  default     = ""
}

variable "max_inactive_revisions" {
  description = "Optional maximum inactive revisions to retain."
  type        = number
  default     = null
}

variable "identity_type" {
  description = "Managed identity type. Supported values are \"SystemAssigned\", \"UserAssigned\", \"SystemAssigned, UserAssigned\", or \"None\"."
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", "None"], var.identity_type)
    error_message = "identity_type must be SystemAssigned, UserAssigned, SystemAssigned, UserAssigned, or None."
  }
}

variable "identity_ids" {
  description = "User-assigned managed identity IDs when identity_type includes UserAssigned."
  type        = list(string)
  default     = []
}

variable "containers" {
  description = "Container definitions for the Container App."
  type = list(object({
    name              = string
    image             = string
    cpu               = number
    memory            = string
    args              = optional(list(string), null)
    command           = optional(list(string), null)
    ephemeral_storage = optional(string, null)
    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })), [])
    volume_mounts = optional(list(object({
      name     = string
      path     = string
      sub_path = optional(string)
    })), [])
  }))
  default = [{
    name   = "app"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]

  validation {
    condition     = length(var.containers) > 0 && alltrue([for container in var.containers : trimspace(container.name) != "" && trimspace(container.image) != ""])
    error_message = "containers must include at least one entry, and each entry must include name and image."
  }
}

variable "init_containers" {
  description = "Optional init container definitions."
  type = list(object({
    name              = string
    image             = string
    cpu               = optional(number)
    memory            = optional(string)
    args              = optional(list(string), null)
    command           = optional(list(string), null)
    ephemeral_storage = optional(string, null)
    env = optional(list(object({
      name        = string
      value       = optional(string)
      secret_name = optional(string)
    })), [])
    volume_mounts = optional(list(object({
      name     = string
      path     = string
      sub_path = optional(string)
    })), [])
  }))
  default = []
}

variable "min_replicas" {
  description = "Minimum number of app replicas."
  type        = number
  default     = 0
}

variable "max_replicas" {
  description = "Maximum number of app replicas."
  type        = number
  default     = 1
}

variable "revision_suffix" {
  description = "Optional revision suffix."
  type        = string
  default     = ""
}

variable "termination_grace_period_seconds" {
  description = "Optional container termination grace period in seconds."
  type        = number
  default     = null
}

variable "cooldown_period_in_seconds" {
  description = "Optional scaling cooldown period in seconds."
  type        = number
  default     = null
}

variable "polling_interval_in_seconds" {
  description = "Optional scaling polling interval in seconds."
  type        = number
  default     = null
}

variable "secrets" {
  description = "Container App secrets. Use Key Vault secret IDs where possible."
  type = list(object({
    name                = string
    value               = optional(string)
    key_vault_secret_id = optional(string)
    identity            = optional(string)
  }))
  default   = []
  sensitive = true
}

variable "registries" {
  description = "Container registry credentials or managed identity references."
  type = list(object({
    server               = string
    username             = optional(string)
    password_secret_name = optional(string)
    identity             = optional(string)
  }))
  default = []
}

variable "ingress" {
  description = "Optional ingress configuration. Set to null for internal/background apps."
  type = object({
    external_enabled           = optional(bool, false)
    target_port                = number
    transport                  = optional(string, "auto")
    allow_insecure_connections = optional(bool, false)
    client_certificate_mode    = optional(string)
    exposed_port               = optional(number)
    traffic_weight = optional(list(object({
      percentage      = number
      latest_revision = optional(bool)
      revision_suffix = optional(string)
      label           = optional(string)
    })), [])
    ip_security_restrictions = optional(list(object({
      name             = string
      action           = string
      ip_address_range = string
      description      = optional(string)
    })), [])
    cors = optional(object({
      allowed_origins           = optional(list(string), [])
      allowed_methods           = optional(list(string), [])
      allowed_headers           = optional(list(string), [])
      exposed_headers           = optional(list(string), [])
      allow_credentials_enabled = optional(bool, false)
      max_age_in_seconds        = optional(number)
    }))
  })
  default = null
}

variable "dapr" {
  description = "Optional Dapr sidecar configuration."
  type = object({
    app_id       = string
    app_port     = optional(number)
    app_protocol = optional(string)
  })
  default = null
}

variable "volumes" {
  description = "Optional template volumes."
  type = list(object({
    name          = string
    storage_type  = string
    storage_name  = optional(string)
    mount_options = optional(string)
  }))
  default = []
}

variable "http_scale_rules" {
  description = "HTTP scale rules."
  type = list(object({
    name                = string
    concurrent_requests = string
    authentication = optional(list(object({
      secret_name       = string
      trigger_parameter = string
    })), [])
  }))
  default = []
}

variable "tcp_scale_rules" {
  description = "TCP scale rules."
  type = list(object({
    name                = string
    concurrent_requests = string
    authentication = optional(list(object({
      secret_name       = string
      trigger_parameter = string
    })), [])
  }))
  default = []
}

variable "custom_scale_rules" {
  description = "KEDA custom scale rules."
  type = list(object({
    name             = string
    custom_rule_type = string
    metadata         = optional(map(string), {})
    identity_id      = optional(string)
    authentication = optional(list(object({
      secret_name       = string
      trigger_parameter = string
    })), [])
  }))
  default = []
}

variable "azure_queue_scale_rules" {
  description = "Azure Queue scale rules."
  type = list(object({
    name         = string
    queue_name   = string
    queue_length = number
    authentication = optional(list(object({
      secret_name       = string
      trigger_parameter = string
    })), [])
  }))
  default = []
}

variable "tags" {
  description = "Tags applied to the Container App."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "containerapp_input_consistency" {
  assert {
    condition     = var.max_replicas >= var.min_replicas
    error_message = "max_replicas must be greater than or equal to min_replicas."
  }

  assert {
    condition     = var.identity_type != "None" || length(var.identity_ids) == 0
    error_message = "identity_ids cannot be set when identity_type is None."
  }
}
