variable "resource_group_name" {
  description = "Existing resource group for the Private DNS zone."
  type        = string
}

variable "zone_name" {
  description = "Private DNS zone name."
  type        = string
  default     = "internal.contoso.com"
}

variable "api_private_ip" {
  description = "IPv4 address for the API A record."
  type        = string
  default     = "10.20.1.10"
}

variable "tags" {
  description = "Tags applied to the zone and record."
  type        = map(string)
  default = {
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}
