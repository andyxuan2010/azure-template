variable "name" {
  description = "Automation Account name."
  type        = string
  default     = "aa-scheduled-operations-dev"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Automation Account."
  type        = string
  default     = "canadacentral"
}

variable "environment" {
  description = "Environment value passed to the runbook and stored as an Automation variable."
  type        = string
  default     = "dev"
}

variable "schedule_start_time" {
  description = "Future RFC3339 timestamp at which the daily schedule becomes active."
  type        = string
  default     = "2030-01-01T00:00:00Z"
}
