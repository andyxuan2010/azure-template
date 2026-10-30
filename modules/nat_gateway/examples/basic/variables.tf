variable "name" {
  description = "NAT Gateway name."
  type        = string
  default     = "nat-example-cc-dev-001"
}

variable "resource_group_name" {
  description = "Existing resource group for the NAT Gateway and created public IP."
  type        = string
}

variable "location" {
  description = "Azure region for the NAT Gateway and created public IP."
  type        = string
}

variable "subnet_ids" {
  description = "Existing subnet IDs in a single VNet."
  type        = list(string)
}

variable "workload" {
  description = "Workload identifier used for generated names."
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
