variable "resource_group_name" {
  description = "Existing resource group for the Storage account."
  type        = string
}

variable "name" {
  description = "Globally unique 3-24 character lowercase alphanumeric Storage account name."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Existing private-endpoint subnet resource ID."
  type        = string
}

variable "private_dns_zone_ids" {
  description = "Blob and DFS private DNS zone IDs keyed by subresource name."
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace resource ID."
  type        = string
}

variable "location" {
  description = "Azure region for the Storage account."
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to Storage resources."
  type        = map(string)
  default     = {}
}
