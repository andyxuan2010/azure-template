variable "name" {
  description = "Globally unique container Web App name."
  type        = string
  default     = "app-orders-container-dev"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Web App."
  type        = string
  default     = "canadacentral"
}

variable "app_service_plan_id" {
  description = "Resource ID of an existing Linux App Service Plan."
  type        = string
}

variable "docker_image_name" {
  description = "Container image and tag."
  type        = string
  default     = "appsvc/staticsite:latest"
}

variable "docker_registry_url" {
  description = "Container registry URL."
  type        = string
  default     = "https://mcr.microsoft.com"
}

variable "use_managed_identity_for_registry" {
  description = "Whether the Web App identity authenticates to a private registry."
  type        = bool
  default     = false
}
