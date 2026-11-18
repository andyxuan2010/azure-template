variable "resource_group_id" {
  description = "Resource group ID where the policy is assigned."
  type        = string
}

variable "required_tag_name" {
  description = "Tag name required by the assignment."
  type        = string
  default     = "Application"
}

variable "excluded_scopes" {
  description = "Child resource IDs excluded from policy evaluation."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Azure region for the assignment identity."
  type        = string
  default     = "canadacentral"
}
