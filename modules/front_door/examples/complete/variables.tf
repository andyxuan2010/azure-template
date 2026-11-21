variable "resource_group_name" {
  description = "Existing resource group for Front Door."
  type        = string
}

variable "origin_hostname" {
  description = "Origin hostname for the application."
  type        = string
}

variable "origin_resource_id" {
  description = "Resource ID of a supported Azure origin for Premium Private Link."
  type        = string
}

variable "origin_private_link_region" {
  description = "Azure region in which Front Door should establish the Private Link connection."
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Organizational tags applied to Front Door profile and endpoint."
  type        = map(string)
  default     = {}
}
