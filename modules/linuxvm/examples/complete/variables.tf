variable "name" {
  description = "Base name for the Linux VMs."
  type        = string
  default     = "vm-orders"
}

variable "resource_group_name" {
  description = "Name of the existing target resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Linux VMs."
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

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs granted VM administration and Entra administrator login."
  type        = list(string)
  default     = []
}

variable "user_group_object_ids" {
  description = "Microsoft Entra group object IDs granted VM read and Entra user login."
  type        = list(string)
  default     = []
}

variable "bastion_name" {
  description = "Name of the existing Azure Bastion host; use an empty string to skip Bastion RBAC."
  type        = string
  default     = ""
}

variable "bastion_resource_group_name" {
  description = "Resource group containing the existing Bastion host."
  type        = string
  default     = ""
}
