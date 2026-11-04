variable "name" {
  description = "NAT Gateway name."
  type        = string
  default     = "nat-example-cc-prod-001"
}

variable "resource_group_name" {
  description = "Existing resource group for the NAT Gateway."
  type        = string
}

variable "location" {
  description = "Azure region for the NAT Gateway."
  type        = string
}

variable "subnet_ids" {
  description = "Existing subnet IDs in a single VNet."
  type        = list(string)
}

variable "public_ip_address_ids" {
  description = "Existing StandardV2 static public IP IDs in the same region."
  type        = list(string)
}

variable "idle_timeout_in_minutes" {
  description = "Outbound flow idle timeout in minutes."
  type        = number
  default     = 10
}

variable "workload" {
  description = "Workload identifier used for generated names."
  type        = string
  default     = "example"
}

variable "app_env" {
  description = "Environment identifier used for generated names."
  type        = string
  default     = "prod"
}

variable "tags" {
  description = "Tags applied to the NAT Gateway."
  type        = map(string)
  default     = {}
}
