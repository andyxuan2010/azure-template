variable "name" {
  description = "Application Gateway name."
  type        = string
  default     = "agw-platform-prod"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Application Gateway."
  type        = string
  default     = "canadacentral"
}

variable "subnet_id" {
  description = "Resource ID of the dedicated Application Gateway subnet."
  type        = string
}

variable "hostname" {
  description = "DNS hostname served by the HTTPS listener."
  type        = string
  default     = "app.example.com"
}

variable "ssl_certificate_data" {
  description = "Base64-encoded PFX certificate data for the HTTPS listener."
  type        = string
  sensitive   = true
}

variable "ssl_certificate_password" {
  description = "Password for the PFX certificate."
  type        = string
  sensitive   = true
}

variable "web_backend_ip_addresses" {
  description = "Web backend IP addresses reachable from the gateway subnet."
  type        = list(string)
  default     = ["192.0.2.10"]
}

variable "api_backend_ip_addresses" {
  description = "API backend IP addresses reachable from the gateway subnet."
  type        = list(string)
  default     = ["198.51.100.10"]
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the existing Log Analytics workspace."
  type        = string
}
