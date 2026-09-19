variable "name" {
  description = "App Service Plan name."
  type        = string
  default     = "asp-orders-autoscale-prod"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the App Service Plan and autoscale setting."
  type        = string
  default     = "canadacentral"
}

variable "autoscale_notification_emails" {
  description = "Operations addresses that receive Azure Monitor autoscale notifications."
  type        = list(string)
  default     = ["platform-operations@example.com"]
}
