variable "name" {
  description = "Private Endpoint name."
  type        = string
  default     = "pep-storage-cc-prod-001"
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

variable "subresource_name" {
  description = "Target service subresource name."
  type        = string
  default     = "blob"
}

variable "member_name" {
  description = "Target service member name required by the static IP configuration."
  type        = string
  default     = "blob"
}

variable "private_ip_address" {
  description = "Static IPv4 address requested in the endpoint subnet."
  type        = string
  default     = "10.20.2.10"
}

variable "private_dns_zone_ids" {
  description = "Existing Private DNS zone IDs."
  type        = list(string)
}

variable "request_message" {
  description = "Manual approval request shown to the target resource owner."
  type        = string
  default     = "Approve the production workload Private Endpoint."
}

variable "inherited_resource_group_tags" {
  description = "Plan-known resource group tags inherited by the endpoint."
  type        = map(string)
  default = {
    Environment = "prod"
    ManagedBy   = "Terraform"
  }
}
