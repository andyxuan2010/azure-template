variable "name" {
  description = "Stable management group ID."
  type        = string
  default     = "corp"
}

variable "display_name" {
  description = "Human-readable management group display name."
  type        = string
  default     = "Corporate"
}

variable "parent_management_group_id" {
  description = "Resource ID of the existing parent management group."
  type        = string
}

variable "subscription_ids" {
  description = "Reviewed subscription GUIDs moved beneath this management group."
  type        = list(string)
}
