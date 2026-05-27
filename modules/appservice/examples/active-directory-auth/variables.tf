variable "resource_group_name" {
  description = "The name of the resource group to create the resources in."
  type        = string
}

variable "location" {
  description = "The name of the location to create the resources in."
  type        = string
}

variable "active_directory_client_id" {
  description = "Application (client) ID of the Microsoft Entra app registration used for App Service authentication."
  type        = string
}

variable "active_directory_client_secret_setting_name" {
  description = "Name of the app setting that stores the Entra app registration client secret."
  type        = string
  default     = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
}

variable "active_directory_tenant_auth_endpoint" {
  description = "Optional tenant auth endpoint. Keep null to default to the currently authenticated tenant."
  type        = string
  default     = null
}

variable "active_directory_login_parameters" {
  description = "Optional login parameters passed to the Entra authorization endpoint."
  type        = map(string)
  default     = {}
}
