variable "name" {
  description = "Optional globally unique API Management service name. Empty generates a name from workload, environment, and instance."
  type        = string
  default     = ""
  nullable    = false

  validation {
    condition     = trimspace(var.name) == "" || can(regex("^[A-Za-z0-9-]{1,50}$", trimspace(var.name)))
    error_message = "name must be empty or contain 1-50 letters, numbers, or hyphens."
  }
}

variable "resource_group_name" {
  description = "Name of the existing resource group for API Management."
  type        = string
  nullable    = false
}

variable "location" {
  description = "Azure region for the API Management service."
  type        = string
  nullable    = false
}

variable "publisher_name" {
  description = "Organization name displayed in the API Management developer portal."
  type        = string
  nullable    = false
}

variable "publisher_email" {
  description = "Contact email displayed in the API Management developer portal."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[^ @]+@[^ @]+\\.[^ @]+$", var.publisher_email))
    error_message = "publisher_email must be a valid email address."
  }
}

variable "sku_name" {
  description = "API Management SKU and capacity, such as Developer_1, Standard_1, or Premium_1."
  type        = string
  default     = "Developer_1"
  nullable    = false

  validation {
    condition     = can(regex("^(Consumption_0|(Developer|Basic|BasicV2|Standard|StandardV2|Premium|PremiumV2)_[1-9][0-9]*)$", var.sku_name))
    error_message = "sku_name must use Consumption_0 or a supported tier with positive capacity."
  }
}

variable "virtual_network_type" {
  description = "API Management network mode. External and Internal require an existing delegated subnet_id."
  type        = string
  default     = "None"
  nullable    = false

  validation {
    condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
    error_message = "virtual_network_type must be None, External, or Internal."
  }
}

variable "subnet_id" {
  description = "Existing subnet ID delegated/configured for API Management. Required for External or Internal network mode."
  type        = string
  default     = null
}

variable "public_network_access_enabled" {
  description = "Whether the API Management management plane accepts public network access."
  type        = bool
  default     = true
  nullable    = false
}

variable "min_api_version" {
  description = "Optional minimum API version accepted by the management plane."
  type        = string
  default     = null
}

variable "enable_http2" {
  description = "Whether HTTP/2 is enabled for the API Management gateway."
  type        = bool
  default     = true
  nullable    = false
}

variable "workload" {
  description = "Workload identifier used when generating the service name."
  type        = string
  default     = "project"
  nullable    = false
}

variable "app_env" {
  description = "Deployment environment used when generating the service name."
  type        = string
  default     = "dev"
  nullable    = false
}

variable "instance" {
  description = "Instance identifier used when generating the service name."
  type        = string
  default     = "001"
  nullable    = false
}

variable "inherit_resource_group_tags" {
  description = "Whether to inherit tags from the existing resource group."
  type        = bool
  default     = true
  nullable    = false
}

variable "inherited_resource_group_tags" {
  description = "Optional resource group tags supplied by the caller to avoid a data source lookup."
  type        = map(string)
  default     = null
}

variable "tags" {
  description = "Additional tags. Caller values override inherited resource group tags."
  type        = map(string)
  default     = {}
  nullable    = false
}
