variable "name" {
  description = "Container App name."
  type        = string
  default     = "ca-worker-cc-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the Container App."
  type        = string
  default     = "canadacentral"
}

variable "container_app_environment_id" {
  description = "Resource ID of an existing Container Apps managed environment."
  type        = string
}

variable "container_image" {
  description = "Approved, version-pinned worker image."
  type        = string
}

variable "worker_identity_id" {
  description = "User-assigned managed identity used by the worker and scaler."
  type        = string
}

variable "storage_account_name" {
  description = "Storage account containing the work queue."
  type        = string
}

variable "queue_name" {
  description = "Azure Storage queue consumed by the worker."
  type        = string
  default     = "work-items"
}
