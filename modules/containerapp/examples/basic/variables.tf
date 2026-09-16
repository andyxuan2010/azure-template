variable "name" {
  description = "Container App name."
  type        = string
  default     = "ca-web-cc-dev-001"
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
  description = "Container image for the web application. Pin an immutable version in real deployments."
  type        = string
  default     = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
}
