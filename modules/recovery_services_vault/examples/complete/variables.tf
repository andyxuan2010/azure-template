variable "resource_group_name" {
  description = "Existing resource group for the Recovery Services vault."
  type        = string
}

variable "location" {
  description = "Region shared by the vault and the data sources that will be protected."
  type        = string
  default     = "canadacentral"
}

variable "tags" {
  description = "Organizational tags for the vault."
  type        = map(string)
  default     = {}
}
