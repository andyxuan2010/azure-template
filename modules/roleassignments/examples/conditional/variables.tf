variable "storage_account_id" {
  description = "Storage account resource ID used as the assignment scope."
  type        = string
}

variable "principal_id" {
  description = "Service principal or managed identity object ID."
  type        = string
}

variable "container_name" {
  description = "Blob container name permitted by the RBAC condition."
  type        = string
  default     = "application"
}
