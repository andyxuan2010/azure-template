variable "resource_group_name" {
  description = "Existing resource group for Front Door."
  type        = string
}

variable "origin_hostname" {
  description = "Public HTTPS origin host name."
  type        = string
}
