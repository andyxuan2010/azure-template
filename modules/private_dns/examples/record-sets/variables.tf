variable "resource_group_name" {
  description = "Existing resource group for the Private DNS zone."
  type        = string
}

variable "zone_name" {
  description = "Private DNS zone name."
  type        = string
  default     = "internal.contoso.com"
}
