variable "resource_group_name" {
  description = "Existing resource group for the VNet."
  type        = string
}

variable "name" {
  description = "VNet name."
  type        = string
  default     = "vnet-spoke-dev"
}

variable "address_space" {
  description = "Non-overlapping VNet address spaces."
  type        = list(string)
  default     = ["10.20.0.0/16"]
}

variable "location" {
  description = "Azure region for the VNet."
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to the VNet."
  type        = map(string)
  default     = {}
}
