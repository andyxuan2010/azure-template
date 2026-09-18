variable "name_prefix" {
  description = "Prefix used when VM names are generated. Generated SQL VM names are capped at 15 characters for Windows computer name compatibility."
  type        = string
  default     = "sql"

  validation {
    condition     = can(regex("^[a-z0-9]{1,6}$", trimspace(var.name_prefix)))
    error_message = "name_prefix must be 1-6 lowercase letters or digits."
  }
}

variable "vm_names" {
  description = "Optional explicit SQL VM names. Leave empty to generate names from name_prefix, workload, location, environment, and instance."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for name in var.vm_names : can(regex("^[a-zA-Z0-9-]{1,15}$", trimspace(name)))
    ])
    error_message = "Each vm_names entry must be 1-15 characters and contain only letters, digits, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the resource group where SQL VMs are deployed."
  type        = string

  validation {
    condition     = trimspace(var.resource_group_name) != ""
    error_message = "resource_group_name cannot be empty."
  }
}

variable "location" {
  description = "Azure region. Leave empty to read the target resource group's location."
  type        = string
  default     = ""
}

variable "location_code" {
  description = "Optional short location code used when names are generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.location_code) == "" || can(regex("^[a-z0-9-]{2,20}$", trimspace(var.location_code)))
    error_message = "location_code must be empty or 2-20 lowercase letters, digits, or hyphens."
  }
}

variable "workload_name" {
  description = "Optional workload segment used when names are generated."
  type        = string
  default     = ""

  validation {
    condition     = trimspace(var.workload_name) == "" || can(regex("^[a-zA-Z0-9-]{1,40}$", trimspace(var.workload_name)))
    error_message = "workload_name must be empty or 1-40 letters, digits, or hyphens."
  }
}

variable "workload" {
  type        = string
  default     = "project"
  description = "Deprecated compatibility input. Supply workload_name or workload tags explicitly where possible."

  validation {
    condition     = length(trimspace(var.workload)) > 0
    error_message = "workload cannot be empty."
  }
}

variable "app_env" {
  description = "Deployment environment used for generated naming."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod", "sbx", "test", "qa", "poc"], var.app_env)
    error_message = "app_env must be one of: dev, staging, prod, sbx, test, qa, poc."
  }
}

variable "instance_start" {
  description = "Starting numeric instance used when names are generated."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_start >= 0 && var.instance_start <= 999
    error_message = "instance_start must be between 0 and 999."
  }
}

variable "vm_count" {
  description = "Number of SQL VMs to deploy."
  type        = number
  default     = 1

  validation {
    condition     = var.vm_count >= 1 && var.vm_count <= 99
    error_message = "vm_count must be between 1 and 99."
  }
}

variable "vm_size" {
  description = "Azure VM size for SQL Server."
  type        = string
  default     = "Standard_E8ds_v5"

  validation {
    condition     = trimspace(var.vm_size) != ""
    error_message = "vm_size cannot be empty."
  }
}

variable "subnet_id" {
  description = "Subnet resource ID for SQL VM NICs."
  type        = string

  validation {
    condition     = can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Network/virtualNetworks/.+/subnets/.+$", var.subnet_id))
    error_message = "subnet_id must be a valid Azure subnet resource ID."
  }
}

variable "private_ip_addresses" {
  description = "Optional static private IP addresses, one per SQL VM. Leave empty for dynamic allocation."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for ip in var.private_ip_addresses : can(cidrhost("${ip}/32", 0))
    ])
    error_message = "private_ip_addresses must contain valid IPv4 addresses."
  }
}

variable "zones" {
  description = "Optional availability zones. Values are distributed across VMs by index. Do not set with availability_set_id."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for zone in var.zones : contains(["1", "2", "3"], zone)
    ])
    error_message = "zones may only contain 1, 2, or 3."
  }
}

variable "availability_set_id" {
  description = "Optional Availability Set ID. Do not set with zones."
  type        = string
  default     = null

  validation {
    condition     = var.availability_set_id == null || can(regex("^/subscriptions/.+/resourceGroups/.+/providers/Microsoft.Compute/availabilitySets/.+$", var.availability_set_id))
    error_message = "availability_set_id must be null or a valid Azure Availability Set resource ID."
  }
}

variable "admin_username" {
  description = "Local administrator username for SQL VMs."
  type        = string
  sensitive   = true

  validation {
    condition     = trimspace(var.admin_username) != ""
    error_message = "admin_username cannot be empty."
  }
}

variable "admin_password" {
  description = "Local administrator password for SQL VMs."
  type        = string
  sensitive   = true

  validation {
    condition     = length(trimspace(nonsensitive(var.admin_password))) >= 12
    error_message = "admin_password must be at least 12 characters."
  }
}

variable "source_image_reference" {
  description = "Source image reference for the SQL VM. Defaults to SQL Server 2022 Standard on Windows Server 2022 Gen2."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "MicrosoftSQLServer"
    offer     = "sql2022-ws2022"
    sku       = "standard-gen2"
    version   = "latest"
  }
}

variable "os_disk" {
  description = "OS disk settings."
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Premium_LRS")
    disk_size_gb         = optional(number, 128)
  })
  default = {}

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk.caching)
    error_message = "os_disk.caching must be None, ReadOnly, or ReadWrite."
  }

  validation {
    condition     = var.os_disk.disk_size_gb >= 64
    error_message = "os_disk.disk_size_gb must be at least 64."
  }
}

variable "data_disks" {
  description = "Managed data disks attached to each SQL VM. LUNs should align with storage_configuration luns when SQL storage configuration is enabled."
  type = map(object({
    lun                  = number
    disk_size_gb         = number
    storage_account_type = optional(string, "Premium_LRS")
    caching              = optional(string, "None")
    disk_iops_read_write = optional(number)
    disk_mbps_read_write = optional(number)
  }))
  default = {
    data01 = {
      lun          = 0
      disk_size_gb = 256
      caching      = "ReadOnly"
    }
    log01 = {
      lun          = 1
      disk_size_gb = 128
      caching      = "None"
    }
    tempdb01 = {
      lun          = 2
      disk_size_gb = 64
      caching      = "ReadOnly"
    }
  }

  validation {
    condition = alltrue([
      for disk in values(var.data_disks) : disk.lun >= 0 && disk.lun <= 63 && disk.disk_size_gb >= 4 && contains(["None", "ReadOnly", "ReadWrite"], disk.caching)
    ])
    error_message = "Each data disk must use lun 0-63, disk_size_gb >= 4, and caching of None, ReadOnly, or ReadWrite."
  }

  validation {
    condition     = length(distinct([for disk in values(var.data_disks) : disk.lun])) == length(values(var.data_disks))
    error_message = "Each data disk must use a unique LUN."
  }
}

variable "identity" {
  description = "Optional managed identity block for SQL VMs."
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type = "SystemAssigned"
  }

  validation {
    condition     = var.identity == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    error_message = "identity.type must be SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned."
  }
}

variable "windows_license_type" {
  description = "Optional Windows license type, commonly Windows_Server when using Azure Hybrid Benefit."
  type        = string
  default     = null

  validation {
    condition     = try(contains(["Windows_Client", "Windows_Server"], var.windows_license_type), true)
    error_message = "windows_license_type must be null, Windows_Client, or Windows_Server."
  }
}

variable "patch_mode" {
  description = "Windows VM patch mode."
  type        = string
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["Manual", "AutomaticByOS", "AutomaticByPlatform"], var.patch_mode)
    error_message = "patch_mode must be Manual, AutomaticByOS, or AutomaticByPlatform."
  }
}

variable "patch_assessment_mode" {
  description = "Windows VM patch assessment mode."
  type        = string
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["ImageDefault", "AutomaticByPlatform"], var.patch_assessment_mode)
    error_message = "patch_assessment_mode must be ImageDefault or AutomaticByPlatform."
  }
}

variable "enable_domain_join" {
  description = "Whether to join SQL VMs to an Active Directory domain using JsonADDomainExtension."
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "Active Directory domain name used when enable_domain_join is true."
  type        = string
  default     = ""
}

variable "domain_ou_path" {
  description = "Optional OU path used by JsonADDomainExtension."
  type        = string
  default     = ""
}

variable "domain_join_user" {
  description = "Domain join username used when enable_domain_join is true."
  type        = string
  default     = ""
  sensitive   = true
}

variable "domain_join_password" {
  description = "Domain join password used when enable_domain_join is true."
  type        = string
  default     = ""
  sensitive   = true
}

variable "domain_join_restart" {
  description = "Whether the domain join extension restarts the VM."
  type        = bool
  default     = false
}

variable "domain_join_options" {
  description = "JsonADDomainExtension join options."
  type        = number
  default     = 3
}

variable "enable_sql_iaas_extension" {
  description = "Whether to register each VM as an Azure SQL VM using azurerm_mssql_virtual_machine."
  type        = bool
  default     = true
}

variable "sql_license_type" {
  description = "SQL Server license type for Azure SQL VM registration."
  type        = string
  default     = "PAYG"

  validation {
    condition     = contains(["PAYG", "AHUB", "DR"], var.sql_license_type)
    error_message = "sql_license_type must be PAYG, AHUB, or DR."
  }
}

variable "sql_connectivity" {
  description = "SQL connectivity settings for Azure SQL VM registration."
  type = object({
    type            = optional(string, "PRIVATE")
    port            = optional(number, 1433)
    update_username = optional(string)
    update_password = optional(string)
  })
  default   = {}
  sensitive = true

  validation {
    condition     = contains(["LOCAL", "PRIVATE", "PUBLIC"], nonsensitive(var.sql_connectivity).type)
    error_message = "sql_connectivity.type must be LOCAL, PRIVATE, or PUBLIC."
  }

  validation {
    condition     = nonsensitive(var.sql_connectivity).port >= 1 && nonsensitive(var.sql_connectivity).port <= 65535
    error_message = "sql_connectivity.port must be between 1 and 65535."
  }
}

variable "r_services_enabled" {
  description = "Whether SQL Server Machine Learning Services / R Services are enabled in SQL VM registration."
  type        = bool
  default     = false
}

variable "sql_virtual_machine_group_id" {
  description = "Optional SQL virtual machine group ID for availability group scenarios."
  type        = string
  default     = null
}

variable "sql_instance" {
  description = "Optional SQL Server instance settings managed through SQL IaaS extension."
  type = object({
    adhoc_workloads_optimization_enabled = optional(bool)
    collation                            = optional(string)
    instant_file_initialization_enabled  = optional(bool)
    lock_pages_in_memory_enabled         = optional(bool)
    max_dop                              = optional(number)
    max_server_memory_mb                 = optional(number)
    min_server_memory_mb                 = optional(number)
  })
  default = null
}

variable "storage_configuration" {
  description = "Optional SQL storage configuration for data, log, and tempdb paths and LUNs."
  type = object({
    disk_type                      = string
    storage_workload_type          = string
    system_db_on_data_disk_enabled = optional(bool)
    data_settings = optional(object({
      default_file_path = string
      luns              = list(number)
    }))
    log_settings = optional(object({
      default_file_path = string
      luns              = list(number)
    }))
    temp_db_settings = optional(object({
      default_file_path      = string
      luns                   = list(number)
      data_file_count        = optional(number)
      data_file_size_mb      = optional(number)
      data_file_growth_in_mb = optional(number)
      log_file_size_mb       = optional(number)
      log_file_growth_mb     = optional(number)
    }))
  })
  default = null

  validation {
    condition     = try(contains(["NEW", "EXTEND", "ADD"], var.storage_configuration.disk_type), true)
    error_message = "storage_configuration.disk_type must be NEW, EXTEND, or ADD."
  }

  validation {
    condition     = try(contains(["GENERAL", "OLTP", "DW"], var.storage_configuration.storage_workload_type), true)
    error_message = "storage_configuration.storage_workload_type must be GENERAL, OLTP, or DW."
  }
}

variable "auto_patching" {
  description = "Optional SQL Server auto patching configuration."
  type = object({
    day_of_week                            = string
    maintenance_window_duration_in_minutes = number
    maintenance_window_starting_hour       = number
  })
  default = null
}

variable "assessment" {
  description = "Optional SQL best practices assessment configuration."
  type = object({
    enabled         = optional(bool)
    run_immediately = optional(bool)
    schedule = optional(object({
      day_of_week        = string
      monthly_occurrence = optional(number)
      start_time         = string
      weekly_interval    = optional(number)
    }))
  })
  default = null
}

variable "auto_backup" {
  description = "Optional SQL Server automated backup configuration."
  type = object({
    retention_period_in_days        = number
    storage_account_access_key      = string
    storage_blob_endpoint           = string
    system_databases_backup_enabled = optional(bool)
    encryption_password             = optional(string)
    manual_schedule = optional(object({
      days_of_week                    = optional(set(string))
      full_backup_frequency           = string
      full_backup_start_hour          = number
      full_backup_window_in_hours     = number
      log_backup_frequency_in_minutes = number
    }))
  })
  default   = null
  sensitive = true
}

variable "key_vault_credential" {
  description = "Optional SQL VM key vault credential configuration."
  type = object({
    name                     = string
    key_vault_url            = string
    service_principal_name   = string
    service_principal_secret = string
  })
  default   = null
  sensitive = true
}

variable "wsfc_domain_credential" {
  description = "Optional WSFC domain credential passwords used with SQL VM group scenarios."
  type = object({
    cluster_bootstrap_account_password = string
    cluster_operator_account_password  = string
    sql_service_account_password       = string
  })
  default   = null
  sensitive = true
}

variable "run_command" {
  description = "Optional VM Run Command executed on each SQL VM after creation/domain join."
  type = object({
    name   = optional(string, "RunCommandInit")
    script = string
  })
  default = null
}

variable "run_command_replace_trigger" {
  description = "Arbitrary value used to force replacement of the Run Command resource when changed."
  type        = any
  default     = null
}

variable "inherit_resource_group_tags" {
  description = "Whether to merge tags from the target resource group into SQL VM resources."
  type        = bool
  default     = true
}

variable "inherited_resource_group_tags" {
  description = "Optional plan-known resource group tags supplied by the root composition. When null and inherit_resource_group_tags is true, the module reads the resource group."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Tags for SQL VM resources."
  type        = map(string)
  default     = {}

  validation {
    condition     = alltrue([for k, v in var.tags : trimspace(k) != "" && trimspace(v) != ""])
    error_message = "All tag keys and values must be non-empty strings."
  }
}
