variable "subscription_guid" {
  description = "GUID of the existing subscription to place under the management group."
  type        = string
}

variable "management_group_id" {
  description = "Target management group resource ID."
  type        = string
}
