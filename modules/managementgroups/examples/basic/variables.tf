variable "name" {
  description = "Stable management group ID."
  type        = string
  default     = "platform"
}

variable "display_name" {
  description = "Human-readable management group display name."
  type        = string
  default     = "Platform"
}

variable "parent_management_group_id" {
  description = "Resource ID of the existing parent management group; null creates beneath the tenant root according to Azure permissions."
  type        = string
  default     = null
}
