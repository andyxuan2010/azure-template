variable "name" {
  description = "Globally unique Log Analytics workspace name."
  type        = string
  default     = "law-orders-prod"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the workspace."
  type        = string
  default     = "canadacentral"
}

variable "reservation_capacity_in_gb_per_day" {
  description = "Reviewed Log Analytics capacity-reservation commitment in GB/day."
  type        = number
  default     = 100
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB; use -1 only when unlimited ingestion is approved."
  type        = number
  default     = 90
}

variable "data_collection_rule_id" {
  description = "Resource ID of the default Data Collection Rule."
  type        = string
}
