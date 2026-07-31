variable "workload_name" {
  description = "Workload segment used in the generated name."
  type        = string
  default     = "shared"
}

variable "environment" {
  description = "Environment segment used in the generated name."
  type        = string
  default     = "poc"
}

variable "location" {
  description = "Azure region for the resource group."
  type        = string
  default     = "canadacentral"
}

variable "location_code" {
  description = "Location code used in the generated name."
  type        = string
  default     = "cc"
}

variable "instance" {
  description = "Instance segment used in the generated name."
  type        = string
  default     = "001"
}
