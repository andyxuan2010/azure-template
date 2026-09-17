variable "resource_group_id" {
  description = "Existing resource group ID used as the assignment scope."
  type        = string
}

variable "principal_id" {
  description = "Microsoft Entra group object ID granted Reader."
  type        = string
}
