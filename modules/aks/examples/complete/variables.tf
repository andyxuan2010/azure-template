variable "resource_group_name" {
  description = "Name of the existing resource group in which to create AKS."
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of the existing subnet used by all node pools."
  type        = string
}

variable "log_analytics_workspace_id" {
  description = "Resource ID of the Log Analytics workspace used by monitoring and diagnostics."
  type        = string
}

variable "admin_group_object_ids" {
  description = "Microsoft Entra group object IDs that receive the AKS cluster-admin role."
  type        = list(string)
  default     = []
}

variable "user_group_object_ids" {
  description = "Microsoft Entra group object IDs that receive the AKS cluster-user role."
  type        = list(string)
  default     = []
}

variable "location" {
  description = "Azure region for AKS."
  type        = string
  default     = "canadacentral"
}

variable "system_node_vm_size" {
  description = "VM SKU for the default system node pool."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "workload_node_vm_size" {
  description = "VM SKU for the workload node pool."
  type        = string
  default     = "Standard_D8s_v5"
}
