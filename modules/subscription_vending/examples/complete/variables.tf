variable "subscription_guid" {
  description = "GUID of the existing subscription to bootstrap."
  type        = string
}

variable "management_group_id" {
  description = "Target management group resource ID."
  type        = string
}

variable "location" {
  description = "Azure region for bootstrap resource groups."
  type        = string
  default     = "canadacentral"
}

variable "workload" {
  description = "Platform or workload naming segment."
  type        = string
  default     = "platform"
}

variable "app_env" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Common tags applied to bootstrap resource groups."
  type        = map(string)
  default     = {}
}
