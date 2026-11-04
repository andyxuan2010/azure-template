variable "name" {
  description = "Production resource group name."
  type        = string
  default     = "rg-orders-cc-prod-001"
}

variable "location" {
  description = "Azure region for the resource group."
  type        = string
  default     = "canadacentral"
}

variable "contributor_group_object_id" {
  description = "Entra group object ID granted Contributor."
  type        = string
}

variable "reader_group_object_id" {
  description = "Entra group object ID granted Reader."
  type        = string
}

variable "application_principal_id" {
  description = "Service principal or managed identity object ID for the custom assignment."
  type        = string
}

variable "rbac_condition" {
  description = "Azure RBAC condition applied to the custom role assignment."
  type        = string
  default     = "@Resource[Microsoft.Storage/storageAccounts/blobServices/containers:name] StringEqualsIgnoreCase 'application'"
}

variable "tags" {
  description = "Complete production resource group tag set."
  type        = map(string)
  default = {
    Environment        = "prod"
    Owner              = "orders-team"
    ManagedBy          = "Terraform"
    DataClassification = "Confidential"
  }
}
