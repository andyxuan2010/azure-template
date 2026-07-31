variable "name" {
  description = "App Service Plan name."
  type        = string
  default     = "asp-orders-prod"
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

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}

variable "app_admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Contributor on the plan."
  type        = list(string)
  default     = []
}

variable "app_user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted Reader on the plan."
  type        = list(string)
  default     = []
}
