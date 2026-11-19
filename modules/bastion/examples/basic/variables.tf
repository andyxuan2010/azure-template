variable "name" {
  description = "Bastion host name."
  type        = string
  default     = "bas-example-cc-dev-001"
}

variable "resource_group_name" {
  description = "Existing resource group for the Bastion host and public IP."
  type        = string
}

variable "location" {
  description = "Azure region for the Bastion host and public IP."
  type        = string
}

variable "subnet_id" {
  description = "Existing dedicated AzureBastionSubnet resource ID."
  type        = string
}

variable "sku" {
  description = "Bastion SKU."
  type        = string
  default     = "Basic"
}

variable "workload" {
  description = "Workload identifier used for tags and generated names."
  type        = string
  default     = "example"
}

variable "app_env" {
  description = "Environment identifier used for generated names."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags applied to module-managed resources."
  type        = map(string)
  default     = {}
}
