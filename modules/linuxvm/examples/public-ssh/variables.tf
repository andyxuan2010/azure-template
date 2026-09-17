variable "name" {
  description = "Base name for the Linux VM."
  type        = string
  default     = "vm-support"
}

variable "resource_group_name" {
  description = "Name of the existing target resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Linux VM."
  type        = string
  default     = "canadacentral"
}

variable "subnet_id" {
  description = "Resource ID of the existing VM subnet."
  type        = string
}

variable "admin_ssh_public_key" {
  description = "SSH public key for the local azureadmin account."
  type        = string
  sensitive   = true
}

variable "trusted_ssh_source_prefixes" {
  description = "Reviewed public IPv4/IPv6 addresses or CIDRs allowed to reach SSH."
  type        = list(string)
}

variable "iac_resource_group_name" {
  description = "Resource group containing shared bootstrap storage and Key Vault."
  type        = string
}

variable "iac_key_vault_name" {
  description = "Name of the shared bootstrap Key Vault."
  type        = string
}

variable "iac_key_vault_id" {
  description = "Resource ID of the shared bootstrap Key Vault."
  type        = string
}

variable "iac_storage_account_name" {
  description = "Name of the shared bootstrap storage account."
  type        = string
}

variable "iac_storage_account_id" {
  description = "Resource ID of the shared bootstrap storage account."
  type        = string
}

variable "iac_storage_primary_blob_endpoint" {
  description = "Primary blob endpoint of the shared bootstrap storage account."
  type        = string
}
