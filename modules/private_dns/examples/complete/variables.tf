variable "resource_group_name" {
  description = "Existing resource group for the Private DNS zones."
  type        = string
}

variable "virtual_network_id" {
  description = "Existing VNet ID linked to both zones."
  type        = string
}

variable "key_vault_private_ip" {
  description = "IPv4 address for the illustrative Key Vault record."
  type        = string
  default     = "10.20.2.10"
}

variable "inherited_resource_group_tags" {
  description = "Plan-known resource group tags inherited by DNS resources."
  type        = map(string)
  default = {
    Environment = "prod"
    CostCenter  = "platform"
  }
}
