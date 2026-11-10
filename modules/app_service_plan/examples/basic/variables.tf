variable "name" {
  description = "App Service Plan name."
  type        = string
  default     = "asp-orders-dev"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the App Service Plan."
  type        = string
  default     = "canadacentral"
}
