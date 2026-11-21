variable "management_group_id" {
  description = "Management group resource ID used for the definition and assignment."
  type        = string
}

variable "allowed_locations" {
  description = "Azure regions allowed below the management group."
  type        = list(string)
  default     = ["canadacentral", "canadaeast"]
}
