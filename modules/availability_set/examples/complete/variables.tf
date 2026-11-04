variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Availability Set and proximity placement group."
  type        = string
  default     = "canadacentral"
}

variable "workload_name" {
  description = "Workload segment used in the generated name."
  type        = string
  default     = "latency"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "prod"
}

variable "platform_fault_domain_count" {
  description = "Fault-domain count supported in the target region."
  type        = number
  default     = 2
}

variable "proximity_placement_group_id" {
  description = "Resource ID of an existing proximity placement group."
  type        = string
}
