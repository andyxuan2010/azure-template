variable "name" {
  description = "Container App name."
  type        = string
  default     = "ca-api-cc-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Container App."
  type        = string
  default     = "canadacentral"
}

variable "container_app_environment_id" {
  description = "Resource ID of an existing Container Apps managed environment."
  type        = string
}

variable "container_image" {
  description = "Approved, version-pinned application image."
  type        = string
}

variable "key_vault_secret_id" {
  description = "Versioned Key Vault secret URI accessible by the Container App identity."
  type        = string
  sensitive   = true
}

variable "revision_suffix" {
  description = "Release identifier for the new revision."
  type        = string
  default     = "v1"
}

variable "allowed_cidr" {
  description = "Trusted IPv4 CIDR permitted by ingress."
  type        = string
  default     = "192.0.2.0/24"
}

variable "allowed_origins" {
  description = "Browser origins permitted by CORS."
  type        = list(string)
  default     = ["https://app.example.com"]
}
