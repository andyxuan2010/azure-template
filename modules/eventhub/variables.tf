variable "resource_group_name" {
  type        = string
  description = "Resource group where the Event Hubs namespace will be deployed."

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty."
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
  description = "Optional Azure region for the Event Hubs namespace. Leave empty to use the target resource group's location."
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  type        = string
  description = "Event Hubs namespace name. Leave empty to auto-generate a unique name."
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 6 &&
      length(trimspace(var.name)) <= 50 &&
      can(regex("^[a-zA-Z][a-zA-Z0-9-]*[a-zA-Z0-9]$", trimspace(var.name)))
    )
    error_message = "name must be empty or 6-50 characters using letters, digits, and hyphens; it must start with a letter and end with a letter or digit."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Event Hubs namespace name is generated."
  default     = "evhns"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Event Hubs namespace name is generated."
  default     = ""

  validation {
    condition     = var.workload_name == "" || can(regex("^[a-zA-Z0-9-]{1,25}$", var.workload_name))
    error_message = "workload_name must be empty or 1-25 characters using letters, digits, or hyphens."
  }
}

variable "app_env" {
  type        = string
  description = "Deployment environment used for standard tags and generated naming."
  default     = "dev"

  validation {
    condition     = contains(["prod", "staging", "dev", "qa", "sbx", "test", "poc"], var.app_env)
    error_message = "app_env must be one of: prod, staging, dev, qa, sbx, test, poc."
  }
}

variable "include_environment_in_name" {
  type        = bool
  description = "Whether generated Event Hubs namespace names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Event Hubs namespace name is generated."
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
    condition     = var.instance == "" || can(regex("^[a-zA-Z0-9-]{1,10}$", var.instance))
    error_message = "instance must be empty or 1-10 characters using letters, digits, or hyphens."
  }
}

variable "use_random_suffix" {
  type        = bool
  description = "Whether generated Event Hubs namespace names should include a random suffix."
  default     = true
}

variable "sku" {
  type        = string
  description = "Event Hubs namespace SKU."
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "sku must be Basic, Standard, or Premium."
  }
}

variable "capacity" {
  type        = number
  description = "Event Hubs namespace capacity or throughput units."
  default     = 1

  validation {
    condition     = var.capacity >= 1
    error_message = "capacity must be at least 1."
  }
}

variable "auto_inflate_enabled" {
  type        = bool
  description = "Whether auto-inflate is enabled for Standard Event Hubs namespaces."
  default     = false
}

variable "maximum_throughput_units" {
  type        = number
  description = "Maximum throughput units when auto-inflate is enabled."
  default     = 0

  validation {
    condition     = var.maximum_throughput_units == 0 || (var.maximum_throughput_units >= 1 && var.maximum_throughput_units <= 40)
    error_message = "maximum_throughput_units must be 0 when auto-inflate is disabled, or 1-40 when enabled."
  }
}

variable "dedicated_cluster_id" {
  type        = string
  description = "Optional Event Hubs Dedicated Cluster resource ID where this namespace should be created."
  default     = ""

  validation {
    condition     = trimspace(var.dedicated_cluster_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/clusters/.+$", var.dedicated_cluster_id))
    error_message = "dedicated_cluster_id must be empty or a valid Event Hubs Dedicated Cluster resource ID."
  }
}

variable "local_authentication_enabled" {
  type        = bool
  description = "Whether SAS/local authentication is enabled. Disable for Entra ID-only access."
  default     = false
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Whether the Event Hubs namespace public endpoint is reachable."
  default     = false
}

variable "minimum_tls_version" {
  type        = string
  description = "Minimum TLS version for the namespace."
  default     = "1.2"

  validation {
    condition     = contains(["1.0", "1.1", "1.2"], var.minimum_tls_version)
    error_message = "minimum_tls_version must be 1.0, 1.1, or 1.2."
  }
}

variable "system_managed_identity_enabled" {
  type        = bool
  description = "Whether to enable a system-assigned managed identity on the namespace."
  default     = false
}

variable "identity_ids" {
  type        = list(string)
  description = "User-assigned managed identity IDs to attach to the Event Hubs namespace. Ignored when legacy identity is set."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for identity_id in var.identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", identity_id))
    ])
    error_message = "identity_ids values must be valid user-assigned managed identity resource IDs."
  }
}

variable "identity" {
  description = "Legacy managed identity configuration. Prefer system_managed_identity_enabled and identity_ids for new usage."
  type = object({
    type         = string
    identity_ids = optional(set(string))
  })
  default = null

  validation {
    condition = contains([
      "SystemAssigned",
      "UserAssigned",
      "SystemAssigned, UserAssigned"
    ], try(var.identity.type, "SystemAssigned"))
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "network_rulesets" {
  description = "Optional namespace firewall configuration using Event Hubs network rule sets."
  type = object({
    default_action                 = optional(string, "Deny")
    trusted_service_access_enabled = optional(bool, false)
    ip_rules = optional(list(object({
      ip_mask = string
      action  = optional(string, "Allow")
    })), [])
    virtual_network_rules = optional(list(object({
      subnet_id                                       = string
      ignore_missing_virtual_network_service_endpoint = optional(bool, false)
    })), [])
  })
  default = null

  validation {
    condition     = contains(["Allow", "Deny"], try(var.network_rulesets.default_action, "Deny"))
    error_message = "network_rulesets.default_action must be Allow or Deny."
  }

  validation {
    condition = alltrue([
      for rule in coalesce(try(var.network_rulesets.ip_rules, null), []) :
      trimspace(rule.ip_mask) != "" && contains(["Allow"], try(rule.action, "Allow"))
    ])
    error_message = "network_rulesets.ip_rules entries must have a non-empty ip_mask and action must be Allow."
  }

  validation {
    condition = alltrue([
      for rule in coalesce(try(var.network_rulesets.virtual_network_rules, null), []) :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", rule.subnet_id))
    ])
    error_message = "network_rulesets.virtual_network_rules subnet_id values must be valid Azure subnet resource IDs."
  }
}

variable "eventhubs" {
  description = "Map of Event Hubs keyed by stable name. Each Event Hub can define capture, retention, consumer groups, and scoped SAS rules."
  type = map(object({
    name              = optional(string)
    partition_count   = optional(number, 2)
    message_retention = optional(number, 1)
    status            = optional(string, "Active")
    retention_description = optional(object({
      cleanup_policy                    = string
      retention_time_in_hours           = optional(number)
      tombstone_retention_time_in_hours = optional(number)
    }))
    capture_description = optional(object({
      enabled             = bool
      encoding            = optional(string, "Avro")
      interval_in_seconds = optional(number)
      size_limit_in_bytes = optional(number)
      skip_empty_archives = optional(bool)
      destination = object({
        name                        = optional(string, "EventHubArchive.AzureBlockBlob")
        archive_name_format         = string
        blob_container_name         = string
        storage_account_id          = string
        storage_authentication_type = optional(string, "StorageSAS")
        storage_authentication_id   = optional(string)
      })
    }))
    consumer_groups = optional(map(object({
      name          = optional(string)
      user_metadata = optional(string)
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
    authorization_rules = optional(map(object({
      name   = optional(string)
      listen = optional(bool, false)
      send   = optional(bool, false)
      manage = optional(bool, false)
      timeouts = optional(object({
        create = optional(string)
        read   = optional(string)
        update = optional(string)
        delete = optional(string)
      }))
    })), {})
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for key, eventhub in var.eventhubs :
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]{0,49}$", try(trimspace(eventhub.name), "") != "" ? trimspace(eventhub.name) : key))
    ])
    error_message = "Each Event Hub name must be 1-50 characters and use letters, digits, periods, underscores, or hyphens."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      eventhub.partition_count >= 1 && eventhub.partition_count <= 1024
    ])
    error_message = "Each eventhubs partition_count must be between 1 and 1024."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      eventhub.message_retention >= 1 && eventhub.message_retention <= 90
    ])
    error_message = "Each eventhubs message_retention must be between 1 and 90 days."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      contains(["Active", "Disabled", "SendDisabled", "ReceiveDisabled"], eventhub.status)
    ])
    error_message = "Each eventhubs status must be Active, Disabled, SendDisabled, or ReceiveDisabled."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      try(eventhub.retention_description, null) == null ? true : contains(["Delete", "Compact"], eventhub.retention_description.cleanup_policy)
    ])
    error_message = "retention_description.cleanup_policy must be Delete or Compact."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      try(eventhub.capture_description, null) == null ? true : contains(["Avro", "AvroDeflate"], eventhub.capture_description.encoding)
    ])
    error_message = "capture_description.encoding must be Avro or AvroDeflate."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      try(eventhub.capture_description, null) == null || try(eventhub.capture_description.interval_in_seconds, null) == null ? true : (
        eventhub.capture_description.interval_in_seconds >= 60 &&
        eventhub.capture_description.interval_in_seconds <= 900
      )
    ])
    error_message = "capture_description.interval_in_seconds must be between 60 and 900."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      try(eventhub.capture_description, null) == null || try(eventhub.capture_description.size_limit_in_bytes, null) == null ? true : (
        eventhub.capture_description.size_limit_in_bytes >= 10485760 &&
        eventhub.capture_description.size_limit_in_bytes <= 524288000
      )
    ])
    error_message = "capture_description.size_limit_in_bytes must be between 10485760 and 524288000."
  }

  validation {
    condition = alltrue([
      for eventhub in values(var.eventhubs) :
      try(eventhub.capture_description, null) == null ? true : (
        try(eventhub.capture_description.destination.name, "EventHubArchive.AzureBlockBlob") == "EventHubArchive.AzureBlockBlob" &&
        contains(["StorageSAS", "SystemAssigned", "UserAssigned"], try(eventhub.capture_description.destination.storage_authentication_type, "StorageSAS"))
      )
    ])
    error_message = "capture_description.destination.name must be EventHubArchive.AzureBlockBlob and storage_authentication_type must be StorageSAS, SystemAssigned, or UserAssigned."
  }

  validation {
    condition = alltrue(flatten([
      for eventhub in values(var.eventhubs) : [
        for rule in values(coalesce(try(eventhub.authorization_rules, null), {})) :
        (try(rule.listen, false) || try(rule.send, false) || try(rule.manage, false)) &&
        (!try(rule.manage, false) || (try(rule.listen, false) && try(rule.send, false)))
      ]
    ]))
    error_message = "Each Event Hub authorization rule must set at least one permission, and manage requires listen and send."
  }
}

variable "authorization_rules" {
  description = "Optional namespace-level authorization rules keyed by stable name. Requires local_authentication_enabled = true."
  type = map(object({
    name   = optional(string)
    listen = optional(bool, false)
    send   = optional(bool, false)
    manage = optional(bool, false)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for rule in values(var.authorization_rules) :
      (try(rule.listen, false) || try(rule.send, false) || try(rule.manage, false)) &&
      (!try(rule.manage, false) || (try(rule.listen, false) && try(rule.send, false)))
    ])
    error_message = "Each authorization_rules entry must set at least one permission, and manage requires listen and send."
  }
}

variable "schema_groups" {
  description = "Optional Event Hubs schema registry groups keyed by stable name."
  type = map(object({
    name                 = optional(string)
    schema_compatibility = string
    schema_type          = string
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      delete = optional(string)
    }))
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for group in values(var.schema_groups) :
      contains(["None", "Backward", "Forward"], group.schema_compatibility) &&
      contains(["Avro", "Json", "Unknown"], group.schema_type) &&
      (group.schema_type != "Json" || group.schema_compatibility == "None")
    ])
    error_message = "Schema groups must use compatibility None, Backward, or Forward; type Avro, Json, or Unknown; Json requires compatibility None."
  }
}

variable "customer_managed_key" {
  description = "Optional Event Hubs namespace customer-managed key configuration."
  type = object({
    key_vault_key_ids                 = list(string)
    infrastructure_encryption_enabled = optional(bool, false)
    user_assigned_identity_id         = optional(string)
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  default = null

  validation {
    condition = try(
      length(var.customer_managed_key.key_vault_key_ids) > 0 &&
      alltrue([
        for key_id in var.customer_managed_key.key_vault_key_ids :
        can(regex("^https://.+/keys/.+$", key_id))
      ]),
      true
    )
    error_message = "customer_managed_key.key_vault_key_ids must contain at least one valid Key Vault key URI."
  }
}

variable "disaster_recovery_config" {
  description = "Optional Geo-Disaster Recovery alias configuration for a paired secondary Event Hubs namespace."
  type = object({
    name                 = string
    partner_namespace_id = string
    timeouts = optional(object({
      create = optional(string)
      read   = optional(string)
      update = optional(string)
      delete = optional(string)
    }))
  })
  default = null

  validation {
    condition = var.disaster_recovery_config == null ? true : (
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,49}$", var.disaster_recovery_config.name)) &&
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+$", var.disaster_recovery_config.partner_namespace_id))
    )
    error_message = "disaster_recovery_config requires a valid alias name and partner Event Hubs namespace resource ID."
  }
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the namespace."
  default     = []
  nullable    = false
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the namespace."
  default     = []
  nullable    = false
}

variable "role_assignments" {
  description = "Additional role assignments to create at the Event Hubs namespace scope, keyed by a stable name."
  type = map(object({
    principal_id                           = string
    role_definition_name                   = optional(string)
    role_definition_id                     = optional(string)
    principal_type                         = optional(string)
    description                            = optional(string)
    name                                   = optional(string)
    condition                              = optional(string)
    condition_version                      = optional(string)
    delegated_managed_identity_resource_id = optional(string)
    skip_service_principal_aad_check       = optional(bool, false)
  }))
  default  = {}
  nullable = false

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      can(regex("^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$", assignment.principal_id))
    ])
    error_message = "Each role_assignments principal_id must be a valid GUID."
  }

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      (try(trimspace(assignment.role_definition_name), "") != "") != (try(trimspace(assignment.role_definition_id), "") != "")
    ])
    error_message = "Each role_assignments entry must set exactly one of role_definition_name or role_definition_id."
  }

  validation {
    condition = alltrue([
      for assignment in var.role_assignments :
      assignment.principal_type == null ? true : contains(["User", "Group", "ServicePrincipal", "ForeignGroup"], assignment.principal_type)
    ])
    error_message = "role_assignments principal_type must be one of User, Group, ServicePrincipal, or ForeignGroup when set."
  }
}

variable "enable_private_endpoint" {
  type        = bool
  description = "Whether to create a private endpoint for the Event Hubs namespace."
  default     = false
}

variable "private_endpoint_subnet_id" {
  type        = string
  description = "Subnet ID for the private endpoint."
  default     = ""

  validation {
    condition     = trimspace(var.private_endpoint_subnet_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/.+$", var.private_endpoint_subnet_id))
    error_message = "private_endpoint_subnet_id must be empty or a valid Azure subnet resource ID."
  }
}

variable "private_endpoint_subnet_name" {
  type        = string
  description = "Subnet name used to resolve the private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_vnet_name" {
  type        = string
  description = "Virtual network name used to resolve the private endpoint subnet when private_endpoint_subnet_id is not set."
  default     = ""
}

variable "private_endpoint_network_resource_group_name" {
  type        = string
  description = "Resource group containing the virtual network used to resolve the private endpoint subnet."
  default     = ""
}

variable "private_endpoint_name_prefix" {
  type        = string
  description = "Prefix used for generated private endpoint names."
  default     = "pep"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,20}$", var.private_endpoint_name_prefix))
    error_message = "private_endpoint_name_prefix must be 1-20 characters using letters, digits, or hyphens."
  }
}

variable "private_service_connection_name_prefix" {
  type        = string
  description = "Prefix used for generated private service connection names."
  default     = "psc"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,20}$", var.private_service_connection_name_prefix))
    error_message = "private_service_connection_name_prefix must be 1-20 characters using letters, digits, or hyphens."
  }
}

variable "private_endpoint_network_interface_name" {
  type        = string
  description = "Optional custom network interface name for the private endpoint."
  default     = ""
}

variable "private_endpoint_manual_connection_enabled" {
  type        = bool
  description = "Whether the private endpoint connection is created as a manual approval request."
  default     = false
}

variable "private_endpoint_request_message" {
  type        = string
  description = "Optional request message used when private_endpoint_manual_connection_enabled is true."
  default     = ""
}

variable "private_endpoint_ip_configurations" {
  description = "Optional static IP configurations for the private endpoint."
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = optional(string, "namespace")
    member_name        = optional(string, "namespace")
  }))
  default  = []
  nullable = false
}

variable "private_dns_zone_id" {
  type        = string
  description = "Optional single private DNS zone ID to attach to the private endpoint. Use private_dns_zone_ids for new configurations."
  default     = ""

  validation {
    condition     = trimspace(var.private_dns_zone_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", var.private_dns_zone_id))
    error_message = "private_dns_zone_id must be empty or a valid Azure Private DNS Zone resource ID."
  }
}

variable "private_dns_zone_ids" {
  type        = list(string)
  description = "Optional list of private DNS zone IDs to attach to the private endpoint."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for zone_id in var.private_dns_zone_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/privateDnsZones/.+$", zone_id))
    ])
    error_message = "private_dns_zone_ids values must be valid Azure Private DNS Zone resource IDs."
  }
}

variable "private_dns_zone_names" {
  type        = list(string)
  description = "Optional private DNS zone names to resolve and attach to the private endpoint when IDs are not supplied. Event Hubs commonly uses privatelink.servicebus.windows.net in Azure public cloud."
  default     = []
  nullable    = false
}

variable "private_dns_zone_resource_group_name" {
  type        = string
  description = "Resource group used to resolve private_dns_zone_names."
  default     = ""
}

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Event Hubs namespace. Diagnostics are also enabled when at least one diagnostic destination is supplied."
  default     = false
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Optional Log Analytics workspace ID used for diagnostics."
  default     = ""

  validation {
    condition     = trimspace(var.log_analytics_workspace_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.OperationalInsights/workspaces/.+$", var.log_analytics_workspace_id))
    error_message = "log_analytics_workspace_id must be empty or a valid Log Analytics workspace resource ID."
  }
}

variable "log_analytics_destination_type" {
  type        = string
  description = "Destination type for Log Analytics diagnostics."
  default     = "Dedicated"

  validation {
    condition     = contains(["Dedicated", "AzureDiagnostics"], var.log_analytics_destination_type)
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }
}

variable "diagnostic_storage_account_id" {
  type        = string
  description = "Optional Storage Account resource ID for diagnostic archive."
  default     = null

  validation {
    condition = (
      var.diagnostic_storage_account_id == null ||
      try(trimspace(var.diagnostic_storage_account_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Storage/storageAccounts/.+$", var.diagnostic_storage_account_id))
    )
    error_message = "diagnostic_storage_account_id must be null, empty, or a valid Storage Account resource ID."
  }
}

variable "diagnostic_eventhub_authorization_rule_id" {
  type        = string
  description = "Optional Event Hubs namespace authorization rule resource ID for diagnostics."
  default     = null

  validation {
    condition = (
      var.diagnostic_eventhub_authorization_rule_id == null ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+/authorizationRules/.+$", var.diagnostic_eventhub_authorization_rule_id))
    )
    error_message = "diagnostic_eventhub_authorization_rule_id must be null, empty, or a valid Event Hubs namespace authorization rule resource ID."
  }
}

variable "diagnostic_eventhub_name" {
  type        = string
  description = "Optional Event Hub name for diagnostics when using an Event Hub destination."
  default     = null
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. When empty, the module uses <namespace-name>-diagnostic-setting."
  default     = ""
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Use diagnostic_log_category_groups for Azure Monitor category groups such as allLogs."
  default     = ["ArchiveLogs", "OperationalLogs", "AutoScaleLogs", "KafkaCoordinatorLogs", "KafkaUserErrorLogs", "EventHubVNetConnectionEvent", "CustomerManagedKeyUserLogs", "RuntimeAuditLogs", "ApplicationMetricsLogs"]
  nullable    = false
}

variable "diagnostic_log_category_groups" {
  type        = list(string)
  description = "Diagnostic log category groups to enable, for example allLogs."
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for value in var.diagnostic_log_category_groups :
      contains(["allLogs", "audit"], value)
    ])
    error_message = "diagnostic_log_category_groups must contain only allLogs or audit."
  }
}

variable "diagnostic_metric_categories" {
  type        = list(string)
  description = "Diagnostic metric categories to enable."
  default     = ["AllMetrics"]
  nullable    = false
}

variable "timeouts" {
  description = "Optional timeouts for Event Hubs namespace create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "private_endpoint_timeouts" {
  description = "Optional timeouts for private endpoint create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "diagnostic_timeouts" {
  description = "Optional timeouts for diagnostic setting create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the Event Hubs namespace and related resources."
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "eventhub_input_consistency" {
  assert {
    condition     = var.identity == null || (!var.system_managed_identity_enabled && length(var.identity_ids) == 0)
    error_message = "Use either legacy identity or the newer system_managed_identity_enabled/identity_ids inputs, not both."
  }

  assert {
    condition     = !var.auto_inflate_enabled || (var.sku == "Standard" && var.maximum_throughput_units >= 1)
    error_message = "auto_inflate_enabled requires sku = Standard and maximum_throughput_units >= 1."
  }

  assert {
    condition     = var.local_authentication_enabled || (length(var.authorization_rules) == 0 && length(flatten([for eventhub in values(var.eventhubs) : keys(coalesce(try(eventhub.authorization_rules, null), {}))])) == 0)
    error_message = "Namespace and Event Hub authorization rules require local_authentication_enabled = true."
  }

  assert {
    condition     = var.customer_managed_key == null || (var.identity != null || var.system_managed_identity_enabled || length(var.identity_ids) > 0)
    error_message = "customer_managed_key requires identity, system_managed_identity_enabled, or identity_ids."
  }

  assert {
    condition = try(
      try(trimspace(var.customer_managed_key.user_assigned_identity_id), "") == "" ||
      contains(distinct(compact(concat(var.identity_ids, try(tolist(var.identity.identity_ids), [])))), var.customer_managed_key.user_assigned_identity_id),
      true
    )
    error_message = "customer_managed_key.user_assigned_identity_id must also be present in identity_ids or legacy identity.identity_ids."
  }

  assert {
    condition = !var.enable_private_endpoint || trimspace(var.private_endpoint_subnet_id) != "" || (
      trimspace(var.private_endpoint_subnet_name) != "" &&
      trimspace(var.private_endpoint_vnet_name) != "" &&
      trimspace(var.private_endpoint_network_resource_group_name) != ""
    )
    error_message = "When enable_private_endpoint is true, provide private_endpoint_subnet_id or the subnet, virtual network, and network resource group names."
  }

  assert {
    condition = (
      length(var.private_dns_zone_names) == 0 ||
      try(trimspace(var.private_dns_zone_resource_group_name), "") != ""
    )
    error_message = "private_dns_zone_resource_group_name must be set when private_dns_zone_names is provided."
  }

  assert {
    condition     = !var.private_endpoint_manual_connection_enabled || trimspace(var.private_endpoint_request_message) != ""
    error_message = "private_endpoint_request_message must be set when private_endpoint_manual_connection_enabled is true."
  }

  assert {
    condition = !var.enable_diagnostics || (
      trimspace(var.log_analytics_workspace_id) != "" ||
      try(trimspace(var.diagnostic_storage_account_id), "") != "" ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
    )
    error_message = "When enable_diagnostics is true, set at least one destination: log_analytics_workspace_id, diagnostic_storage_account_id, or diagnostic_eventhub_authorization_rule_id."
  }

  assert {
    condition = (
      try(trimspace(var.diagnostic_eventhub_name), "") == "" ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") != ""
    )
    error_message = "diagnostic_eventhub_authorization_rule_id must be set when diagnostic_eventhub_name is provided."
  }
}
