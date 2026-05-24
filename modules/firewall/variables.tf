variable "resource_group_name" {
  description = "Resource group where the Azure Firewall and related resources will be created."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "inherit_resource_group_tags" {
  type        = bool
  description = "Whether to merge tags from the target resource group into module resources. The module only reads the resource group when this is true or location is empty."
  default     = false
}

variable "location" {
  description = "Optional Azure region for the firewall. Leave empty to use the target resource group's location."
  type        = string
  default     = ""

  validation {
    condition     = var.location == "" || can(regex("^[a-z0-9-]+$", var.location))
    error_message = "location must be empty or a valid Azure region identifier."
  }
}

variable "name" {
  description = "Azure Firewall name. Leave empty to auto-generate a standardized name."
  type        = string
  default     = ""

  validation {
    condition = trimspace(var.name) == "" || (
      length(trimspace(var.name)) >= 1 &&
      length(trimspace(var.name)) <= 80 &&
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9._-]*[a-zA-Z0-9_]$", trimspace(var.name)))
    )
    error_message = "name must be empty or 1-80 characters using letters, digits, periods, underscores, or hyphens, and must start and end with an alphanumeric character or underscore."
  }
}

variable "name_prefix" {
  type        = string
  description = "Prefix used when the Azure Firewall name is generated."
  default     = "afw"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,15}$", var.name_prefix))
    error_message = "name_prefix must be 1-15 characters using letters, digits, or hyphens."
  }
}

variable "workload_name" {
  type        = string
  description = "Optional workload segment used when the Azure Firewall name is generated."
  default     = ""

  validation {
    condition     = var.workload_name == "" || can(regex("^[a-zA-Z0-9-]{1,35}$", var.workload_name))
    error_message = "workload_name must be empty or 1-35 characters using letters, digits, or hyphens."
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
  description = "Whether generated Azure Firewall names include app_env."
  default     = true
}

variable "location_code" {
  type        = string
  description = "Optional short location code used when the Azure Firewall name is generated."
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
  description = "Whether generated Azure Firewall names should include a random suffix."
  default     = true
}

variable "sku_tier" {
  description = "Azure Firewall SKU tier."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku_tier)
    error_message = "sku_tier must be Basic, Standard, or Premium."
  }
}

variable "sku_name" {
  description = "Azure Firewall deployment mode."
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.sku_name)
    error_message = "sku_name must be AZFW_VNet or AZFW_Hub."
  }
}

variable "subnet_id" {
  description = "AzureFirewallSubnet ID for VNet-deployed Azure Firewall. Required when sku_name is AZFW_VNet."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.subnet_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/AzureFirewallSubnet$", var.subnet_id))
    error_message = "subnet_id must be empty or a valid AzureFirewallSubnet resource ID."
  }
}

variable "zones" {
  description = "Optional availability zones. For production regions that support zones, prefer multiple zones such as [\"1\", \"2\", \"3\"]."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for zone in var.zones :
      contains(["1", "2", "3"], zone)
    ])
    error_message = "zones can contain only 1, 2, or 3."
  }
}

variable "create_public_ip" {
  description = "Whether to create Standard public IP addresses for VNet-deployed firewalls."
  type        = bool
  default     = true
}

variable "public_ip_count" {
  description = "Number of Standard public IP addresses to create when create_public_ip is true."
  type        = number
  default     = 1

  validation {
    condition     = var.public_ip_count >= 0 && var.public_ip_count <= 250
    error_message = "public_ip_count must be between 0 and 250."
  }
}

variable "public_ip_ids" {
  description = "Existing Standard public IP resource IDs to attach to VNet-deployed firewalls."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for public_ip_id in var.public_ip_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/publicIPAddresses/.+$", public_ip_id))
    ])
    error_message = "public_ip_ids values must be valid Azure Public IP resource IDs."
  }
}

variable "public_ip_name" {
  description = "Name for the first created public IP. Leave empty to derive from the firewall name."
  type        = string
  default     = ""
}

variable "public_ip_sku_tier" {
  description = "Public IP SKU tier."
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.public_ip_sku_tier)
    error_message = "public_ip_sku_tier must be Regional or Global."
  }
}

variable "public_ip_version" {
  description = "Public IP address version."
  type        = string
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "IPv6"], var.public_ip_version)
    error_message = "public_ip_version must be IPv4 or IPv6."
  }
}

variable "public_ip_idle_timeout_in_minutes" {
  description = "TCP idle timeout in minutes for created public IPs."
  type        = number
  default     = 4

  validation {
    condition     = var.public_ip_idle_timeout_in_minutes >= 4 && var.public_ip_idle_timeout_in_minutes <= 30
    error_message = "public_ip_idle_timeout_in_minutes must be between 4 and 30."
  }
}

variable "public_ip_prefix_id" {
  description = "Optional public IP prefix ID used by created public IPs."
  type        = string
  default     = ""
}

variable "public_ip_domain_name_labels" {
  description = "Optional DNS labels for created firewall public IPs by zero-based index."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "public_ip_domain_name_label_scope" {
  description = "Optional domain name label scope for created public IPs."
  type        = string
  default     = null

  validation {
    condition     = contains(["TenantReuse", "SubscriptionReuse", "ResourceGroupReuse", "NoReuse"], coalesce(var.public_ip_domain_name_label_scope, "NoReuse"))
    error_message = "public_ip_domain_name_label_scope must be null, TenantReuse, SubscriptionReuse, ResourceGroupReuse, or NoReuse."
  }
}

variable "public_ip_reverse_fqdn" {
  description = "Optional reverse FQDN for created firewall public IPs."
  type        = string
  default     = ""
}

variable "public_ip_tags" {
  description = "Optional IP tags for created public IPs."
  type        = map(string)
  default     = {}
  nullable    = false
}

variable "ip_configuration_name" {
  description = "Name for the primary Azure Firewall IP configuration."
  type        = string
  default     = "ipconfig"
}

variable "management_subnet_id" {
  description = "AzureFirewallManagementSubnet ID for forced tunneling scenarios."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.management_subnet_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualNetworks/.+/subnets/AzureFirewallManagementSubnet$", var.management_subnet_id))
    error_message = "management_subnet_id must be empty or a valid AzureFirewallManagementSubnet resource ID."
  }
}

variable "management_public_ip_id" {
  description = "Existing Standard public IP ID for the management IP configuration. When empty and management_subnet_id is set, the module creates one."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.management_public_ip_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/publicIPAddresses/.+$", var.management_public_ip_id))
    error_message = "management_public_ip_id must be empty or a valid Azure Public IP resource ID."
  }
}

variable "management_public_ip_name" {
  description = "Name for the created management public IP."
  type        = string
  default     = ""
}

variable "management_public_ip_domain_name_label" {
  description = "Optional DNS label for the created management public IP."
  type        = string
  default     = ""
}

variable "management_public_ip_prefix_id" {
  description = "Optional public IP prefix ID used by the created management public IP."
  type        = string
  default     = ""
}

variable "management_ip_configuration_name" {
  description = "Name for the Azure Firewall management IP configuration."
  type        = string
  default     = "mgmt-ipconfig"
}

variable "virtual_hub_id" {
  description = "Virtual Hub ID for Virtual WAN hub-deployed firewalls. Required when sku_name is AZFW_Hub."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.virtual_hub_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/virtualHubs/.+$", var.virtual_hub_id))
    error_message = "virtual_hub_id must be empty or a valid Virtual Hub resource ID."
  }
}

variable "virtual_hub_public_ip_count" {
  description = "Number of public IPs assigned by Azure for a Virtual Hub firewall."
  type        = number
  default     = 1

  validation {
    condition     = var.virtual_hub_public_ip_count >= 1 && var.virtual_hub_public_ip_count <= 250
    error_message = "virtual_hub_public_ip_count must be between 1 and 250."
  }
}

variable "create_firewall_policy" {
  description = "Whether to create and attach an Azure Firewall Policy."
  type        = bool
  default     = true
}

variable "firewall_policy_id" {
  description = "Existing Firewall Policy ID to attach when create_firewall_policy is false."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.firewall_policy_id) == "" || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.Network/firewallPolicies/.+$", var.firewall_policy_id))
    error_message = "firewall_policy_id must be empty or a valid Azure Firewall Policy resource ID."
  }
}

variable "firewall_policy_name" {
  description = "Firewall Policy name. Leave empty to derive from the firewall name."
  type        = string
  default     = ""
}

variable "firewall_policy_sku" {
  description = "Firewall Policy SKU tier. Leave empty to inherit sku_tier."
  type        = string
  default     = ""

  validation {
    condition     = var.firewall_policy_sku == "" || contains(["Basic", "Standard", "Premium"], var.firewall_policy_sku)
    error_message = "firewall_policy_sku must be empty, Basic, Standard, or Premium."
  }
}

variable "base_policy_id" {
  description = "Optional base Firewall Policy ID."
  type        = string
  default     = ""
}

variable "threat_intelligence_mode" {
  description = "Threat intelligence mode for the Firewall Policy or firewall."
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Alert", "Deny", "Off"], var.threat_intelligence_mode)
    error_message = "threat_intelligence_mode must be Alert, Deny, or Off."
  }
}

variable "dns_proxy_enabled" {
  description = "Whether DNS proxy is enabled. Recommended when network rules use FQDNs."
  type        = bool
  default     = true
}

variable "dns_servers" {
  description = "Optional custom DNS servers for Azure Firewall or the attached policy."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "private_ip_ranges" {
  description = "Private CIDR ranges that Azure Firewall should not SNAT. Leave empty to use Azure Firewall defaults."
  type        = list(string)
  default     = []
  nullable    = false
}

variable "auto_learn_private_ranges_enabled" {
  description = "Whether the Firewall Policy auto-learns private IP ranges."
  type        = bool
  default     = false
}

variable "sql_redirect_allowed" {
  description = "Whether SQL redirect traffic filtering is allowed in the Firewall Policy."
  type        = bool
  default     = false
}

variable "firewall_policy_identity_ids" {
  description = "User-assigned managed identity IDs to attach to the Firewall Policy."
  type        = list(string)
  default     = []
  nullable    = false

  validation {
    condition = alltrue([
      for identity_id in var.firewall_policy_identity_ids :
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.ManagedIdentity/userAssignedIdentities/.+$", identity_id))
    ])
    error_message = "firewall_policy_identity_ids values must be valid user-assigned managed identity resource IDs."
  }
}

variable "policy_insights" {
  description = "Optional Firewall Policy insights configuration."
  type = object({
    enabled                            = bool
    default_log_analytics_workspace_id = string
    retention_in_days                  = optional(number)
    log_analytics_workspaces = optional(list(object({
      id                = string
      firewall_location = string
    })), [])
  })
  default = null
}

variable "intrusion_detection" {
  description = "Optional Premium Firewall Policy IDPS configuration."
  type = object({
    mode           = optional(string, "Alert")
    private_ranges = optional(list(string))
    signature_overrides = optional(list(object({
      id    = optional(string)
      state = optional(string)
    })), [])
    traffic_bypass = optional(list(object({
      name                  = string
      protocol              = string
      description           = optional(string)
      source_addresses      = optional(set(string))
      source_ip_groups      = optional(set(string))
      destination_addresses = optional(set(string))
      destination_ip_groups = optional(set(string))
      destination_ports     = optional(set(string))
    })), [])
  })
  default = null
}

variable "threat_intelligence_allowlist_fqdns" {
  description = "FQDNs excluded from threat intelligence filtering."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "threat_intelligence_allowlist_ip_addresses" {
  description = "IP addresses or CIDRs excluded from threat intelligence filtering."
  type        = set(string)
  default     = []
  nullable    = false
}

variable "tls_certificate" {
  description = "Optional Premium TLS inspection certificate configuration."
  type = object({
    name                = string
    key_vault_secret_id = string
  })
  default = null
}

variable "explicit_proxy" {
  description = "Optional Firewall Policy explicit proxy configuration."
  type = object({
    enabled         = optional(bool)
    http_port       = optional(number)
    https_port      = optional(number)
    enable_pac_file = optional(bool)
    pac_file_port   = optional(number)
    pac_file        = optional(string)
  })
  default = null
}

variable "application_rule_collections" {
  description = "Backward-compatible application rule collections placed into the default rule collection group."
  type = map(object({
    name     = optional(string)
    priority = number
    action   = string
    rules = map(object({
      name                  = optional(string)
      description           = optional(string)
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
      destination_addresses = optional(list(string), [])
      destination_fqdns     = optional(list(string), [])
      destination_urls      = optional(list(string), [])
      destination_fqdn_tags = optional(list(string), [])
      terminate_tls         = optional(bool)
      web_categories        = optional(list(string), [])
      protocols = list(object({
        type = string
        port = number
      }))
      http_headers = optional(list(object({
        name  = string
        value = string
      })), [])
    }))
  }))
  default  = {}
  nullable = false
}

variable "network_rule_collections" {
  description = "Backward-compatible network rule collections placed into the default rule collection group."
  type = map(object({
    name     = optional(string)
    priority = number
    action   = string
    rules = map(object({
      name                  = optional(string)
      description           = optional(string)
      source_addresses      = optional(list(string), [])
      source_ip_groups      = optional(list(string), [])
      destination_addresses = optional(list(string), [])
      destination_ip_groups = optional(list(string), [])
      destination_fqdns     = optional(list(string), [])
      destination_ports     = list(string)
      protocols             = list(string)
    }))
  }))
  default  = {}
  nullable = false
}

variable "nat_rule_collections" {
  description = "Backward-compatible NAT rule collections placed into the default rule collection group."
  type = map(object({
    name     = optional(string)
    priority = number
    action   = string
    rules = map(object({
      name                = optional(string)
      description         = optional(string)
      source_addresses    = optional(list(string), [])
      source_ip_groups    = optional(list(string), [])
      destination_address = optional(string)
      destination_ports   = optional(list(string), [])
      translated_address  = optional(string)
      translated_fqdn     = optional(string)
      translated_port     = string
      protocols           = list(string)
    }))
  }))
  default  = {}
  nullable = false
}

variable "rule_collection_group_priority" {
  description = "Priority for the backward-compatible default rule collection group."
  type        = number
  default     = 100

  validation {
    condition     = var.rule_collection_group_priority >= 100 && var.rule_collection_group_priority <= 65000
    error_message = "rule_collection_group_priority must be between 100 and 65000."
  }
}

variable "rule_collection_groups" {
  description = "Additional Firewall Policy rule collection groups keyed by stable name."
  type = map(object({
    name     = optional(string)
    priority = number
    application_rule_collections = optional(map(object({
      name     = optional(string)
      priority = number
      action   = string
      rules = map(object({
        name                  = optional(string)
        description           = optional(string)
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_addresses = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_urls      = optional(list(string), [])
        destination_fqdn_tags = optional(list(string), [])
        terminate_tls         = optional(bool)
        web_categories        = optional(list(string), [])
        protocols = list(object({
          type = string
          port = number
        }))
        http_headers = optional(list(object({
          name  = string
          value = string
        })), [])
      }))
    })), {})
    network_rule_collections = optional(map(object({
      name     = optional(string)
      priority = number
      action   = string
      rules = map(object({
        name                  = optional(string)
        description           = optional(string)
        source_addresses      = optional(list(string), [])
        source_ip_groups      = optional(list(string), [])
        destination_addresses = optional(list(string), [])
        destination_ip_groups = optional(list(string), [])
        destination_fqdns     = optional(list(string), [])
        destination_ports     = list(string)
        protocols             = list(string)
      }))
    })), {})
    nat_rule_collections = optional(map(object({
      name     = optional(string)
      priority = number
      action   = string
      rules = map(object({
        name                = optional(string)
        description         = optional(string)
        source_addresses    = optional(list(string), [])
        source_ip_groups    = optional(list(string), [])
        destination_address = optional(string)
        destination_ports   = optional(list(string), [])
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = string
        protocols           = list(string)
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
}

variable "app_admin_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Contributor access to the firewall."
  default     = []
  nullable    = false
}

variable "app_user_group" {
  type        = list(string)
  description = "Optional list of Entra group display names or object IDs that will have Reader access to the firewall."
  default     = []
  nullable    = false
}

variable "role_assignments" {
  description = "Additional role assignments to create at the Azure Firewall scope, keyed by stable name."
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

variable "enable_diagnostics" {
  type        = bool
  description = "Whether to create diagnostic settings on the Azure Firewall. Diagnostics are also enabled when at least one diagnostic destination is supplied."
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
  description = "Optional Event Hub authorization rule resource ID for diagnostics."
  default     = null

  validation {
    condition = (
      var.diagnostic_eventhub_authorization_rule_id == null ||
      try(trimspace(var.diagnostic_eventhub_authorization_rule_id), "") == "" ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+/authorizationRules/.+$", var.diagnostic_eventhub_authorization_rule_id)) ||
      can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft\\.EventHub/namespaces/.+/eventhubs/.+/authorizationRules/.+$", var.diagnostic_eventhub_authorization_rule_id))
    )
    error_message = "diagnostic_eventhub_authorization_rule_id must be null, empty, or a valid Event Hub authorization rule resource ID."
  }
}

variable "diagnostic_eventhub_name" {
  type        = string
  description = "Optional Event Hub name for diagnostics when using an Event Hub destination."
  default     = null
}

variable "diagnostic_setting_name" {
  type        = string
  description = "Optional diagnostic setting name. When empty, the module uses <firewall-name>-diagnostic-setting."
  default     = ""
}

variable "diagnostic_log_categories" {
  type        = list(string)
  description = "Diagnostic log categories to enable. Use diagnostic_log_category_groups for Azure Monitor category groups such as allLogs."
  default     = ["AZFWApplicationRule", "AZFWNetworkRule", "AZFWNatRule", "AZFWThreatIntel", "AZFWDnsQuery", "AZFWIdpsSignature"]
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
  description = "Optional timeouts for Azure Firewall create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "firewall_policy_timeouts" {
  description = "Optional timeouts for Firewall Policy create, read, update, and delete operations."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}

variable "public_ip_timeouts" {
  description = "Optional timeouts for created Public IP create, read, update, and delete operations."
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
  description = "Tags applied to firewall resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}

check "firewall_input_consistency" {
  assert {
    condition = (
      (var.sku_name == "AZFW_VNet" && trimspace(var.subnet_id) != "") ||
      (var.sku_name == "AZFW_Hub" && trimspace(var.virtual_hub_id) != "")
    )
    error_message = "sku_name = AZFW_VNet requires subnet_id. sku_name = AZFW_Hub requires virtual_hub_id."
  }

  assert {
    condition = (
      var.sku_name != "AZFW_VNet" ||
      local.firewall_policy_attached ||
      local.management_ip_configuration_set ||
      (var.create_public_ip && var.public_ip_count > 0) ||
      length(var.public_ip_ids) > 0
    )
    error_message = "VNet-deployed firewalls require at least one public IP unless management_ip_configuration is configured."
  }

  assert {
    condition     = var.create_firewall_policy || trimspace(var.firewall_policy_id) != "" || length(local.rule_collection_groups) == 0
    error_message = "Rule collection groups require create_firewall_policy = true or a valid firewall_policy_id."
  }

  assert {
    condition     = !local.management_ip_configuration_set || var.sku_name == "AZFW_VNet"
    error_message = "management_subnet_id is only supported with sku_name = AZFW_VNet."
  }

  assert {
    condition     = var.intrusion_detection == null || (trimspace(var.firewall_policy_sku) != "" ? var.firewall_policy_sku : var.sku_tier) == "Premium"
    error_message = "intrusion_detection requires Premium Firewall Policy SKU."
  }

  assert {
    condition     = var.tls_certificate == null || (trimspace(var.firewall_policy_sku) != "" ? var.firewall_policy_sku : var.sku_tier) == "Premium"
    error_message = "tls_certificate requires Premium Firewall Policy SKU."
  }

  assert {
    condition = alltrue(flatten(concat(
      [
        for collection in values(var.application_rule_collections) : [
          for rule in values(collection.rules) :
          (
            length(coalesce(try(rule.destination_urls, null), [])) == 0 &&
            length(coalesce(try(rule.web_categories, null), [])) == 0 &&
            coalesce(try(rule.terminate_tls, null), false) == false
          ) || (trimspace(var.firewall_policy_sku) != "" ? var.firewall_policy_sku : var.sku_tier) == "Premium"
        ]
      ],
      [
        for group in values(var.rule_collection_groups) : flatten([
          for collection in values(coalesce(try(group.application_rule_collections, null), {})) : [
            for rule in values(collection.rules) :
            (
              length(coalesce(try(rule.destination_urls, null), [])) == 0 &&
              length(coalesce(try(rule.web_categories, null), [])) == 0 &&
              coalesce(try(rule.terminate_tls, null), false) == false
            ) || (trimspace(var.firewall_policy_sku) != "" ? var.firewall_policy_sku : var.sku_tier) == "Premium"
          ]
        ])
      ]
    )))
    error_message = "Application rule destination_urls, web_categories, and terminate_tls require Premium Firewall Policy SKU."
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
