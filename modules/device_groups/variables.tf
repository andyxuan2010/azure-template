variable "groups" {
  description = "Map of Entra security groups and optional dynamic membership rules."
  type        = map(object({ display_name = string, description = optional(string), membership_rule = optional(string) }))
  default     = {}
}
