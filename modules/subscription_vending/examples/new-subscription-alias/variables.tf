variable "subscription_alias_name" {
  description = "Unique subscription alias used by the Azure billing API."
  type        = string
}

variable "subscription_name" {
  description = "Display name for the new subscription."
  type        = string
}

variable "billing_scope_id" {
  description = "Microsoft Customer Agreement billing scope resource ID."
  type        = string
}
