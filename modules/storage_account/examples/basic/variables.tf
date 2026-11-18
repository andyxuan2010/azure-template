variable "resource_group_name" {
  description = "Existing resource group for the Storage account."
  type        = string
}

variable "name" {
  description = "Globally unique 3-24 character lowercase alphanumeric Storage account name."
  type        = string
}

variable "location" {
  description = "Azure region for the Storage account."
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Tags applied to the Storage account."
  type        = map(string)
  default     = {}
}
