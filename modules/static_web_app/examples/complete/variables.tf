variable "name" {
  description = "Globally unique Static Web App name."
  type        = string
  default     = "swa-platform-complete-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Static Web App."
  type        = string
  default     = "canadacentral"
}

variable "app_env" {
  description = "Application environment setting."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags applied to the Static Web App."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
    Component   = "static-web-app"
  }
}
