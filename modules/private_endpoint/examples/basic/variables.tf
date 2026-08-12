variable "name" {
  description = "Private Endpoint name."
  type        = string
  default     = "pep-storage-cc-dev-001"
}

variable "resource_group_name" {
  description = "Existing resource group for the Private Endpoint."
  type        = string
}

variable "location" {
  description = "Azure region for the Private Endpoint."
  type        = string
  default     = "canadacentral"
}

variable "subnet_id" {
  description = "Existing Private Endpoint subnet ID."
  type        = string
}

variable "private_connection_resource_id" {
  description = "Target PaaS resource ID."
  type        = string
}

variable "subresource_names" {
  description = "Target service subresource names."
  type        = list(string)
  default     = ["blob"]
}

variable "private_dns_zone_ids" {
  description = "Existing Private DNS zone IDs."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags applied to the Private Endpoint."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
