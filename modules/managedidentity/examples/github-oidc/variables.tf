variable "name" {
  description = "Name of the GitHub workload identity."
  type        = string
  default     = "id-github-prod-001"
}

variable "resource_group_name" {
  description = "Name of the existing resource group."
  type        = string
}

variable "location" {
  description = "Azure region for the managed identity."
  type        = string
  default     = "canadacentral"
}

variable "github_repository" {
  description = "GitHub repository in owner/name form."
  type        = string
}

variable "github_environment" {
  description = "Protected GitHub environment trusted by this identity."
  type        = string
  default     = "production"
}
