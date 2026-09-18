variable "resource_group_name" {
  description = "Name of the existing resource group in which to create AKS."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of the existing subnet used by the system node pool."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs that receive the AKS cluster-admin role."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Azure region for AKS."
  type        = string
  default     = "canadacentral"
}

variable "workload_name" {
  description = "Workload component used for generated naming."
  type        = string
  default     = "platform"
}

variable "app_env" {
  description = "Deployment environment used by module naming and tagging."
  type        = string
  default     = "dev"
}

variable "system_node_vm_size" {
  description = "VM SKU for the default system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}
