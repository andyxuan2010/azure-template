variable "common_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "Dev"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
  }
}

#resource group specific tags
variable "rg_tags" {
  type = map(any)

  default = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "Environment"                       = "Dev"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
    "Project Status"                    = "test"
    "workload"                          = "iactest"
    "IaC"                               = "Terraform"
    "Requested By"                      = "CCOE"
    "Provisioned By"                    = "admin@2join.us"
    "Technical contact"                 = "admin@2join.us"
    "Business contact"                  = "admin@2join.us"
    "ADO Project"                       = "CCoE-Infra-IaC"
    "ADO Repo"                          = "adf-lab"
    "ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/adf-lab"
  }
}


#resource group specific tags
variable "adf_tags" {
  type = map(any)
  default = {
    "resourceType" = "ADF"
  }
}

#resource group specific tags
variable "sqldb_tags" {
  type = map(any)
  default = {
    "resourceType" = "SQLDB"
  }
}
#resource group specific tags
variable "sqlmidb_tags" {
  type = map(any)
  default = {
    "ResourceType"                            = "SQLMIDB"
    "Tier2:Application Name"                  = "CCOE INFRA IAC"
    "Tier2:Application Owner"                 = "CCOE"
    "Tier2:AppSupport Team"                   = "CCOE"
    "Tier2:Approval Group"                    = "CCOE"
    "Tier2:Business Owner"                    = "CCOE"
    "Tier2:Environment"                       = "Dev"
    "Tier2:InfraSupport Team"                 = "CCOE"
    "Tier2:Maintenance Window"                = "CCOE"
    "Tier2:Project Name"                      = "CCOE INFRA IAC"
    "Tier2:Project Number"                    = "N/A"
    "Tier2:RPO-RTO"                           = "48H/24H"
    "Tier2:Run Cost(Approved Run Budget)-USD" = "100"
    "Tier2:workload"                          = "iactest"
    "Tier2:Requested By"                      = "CCOE"
    "Tier2:Provisioned By"                    = "admin@2join.us"
    "Tier2:Technical contact"                 = "admin@2join.us"
    "Tier2:Business contact"                  = "admin@2join.us"
    "Tier2:ADO Project"                       = "CCoE-Infra-IaC"
    "Tier2:ADO Repo"                          = "adf-lab"
    "Tier2:ADO Link"                          = "https://dev.azure.com/CCOE-Azure/CCoE-Infra-IaC/_git/adf-lab"
  }
}
variable "location" {
  default     = "canadacentral"
  description = "The Azure Region in which all resources in this example should be created."
}

variable "app_env" {
  type        = string
  description = "Environment, the environment name such as 'stg', 'prd', 'dev'"
  validation {
    condition     = var.app_env == null ? true : contains(["prod", "qa", "dev", "test", "sbx"], var.app_env)
    error_message = "Only a valid azure names are expected here such as prod."
  }
}


variable "emachine-pub-key" {
  default = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDIqfriZJbopqGHXo1gVfxo7LNF7rx+Yq1qSFpLeojDS4DWr/a8v2dpevDf95Xku/BGLZ16eRQFlW4/YFfhpPIy1sYVlaJQVOiALN8sk1R5OuGjLXy2e22SRVgH0LQehHCLwmszjuLhbmDO8qjNnzm0JIYHmv4+VkZ56LI8rTiPozHmKGxgKfhKhV1vh9NzdCnj7Nh/iQWAU82X5UzYU6J6t7Ape1bp4C74yPH3NOcVcV51qKZXiamfM2PfPnU11I+Wd7Ho8l1yvpUUZe0FdSBZtp7oWya+oPy5AXJlfuMCq5WjVUO9LCvpZMsJWQDhocMFuDRiNw4+0G/XnathEiRP root@emachine
EOT
}
variable "vm-pub-key" {
  default = <<EOT
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCjoftGI4Wgwc6YHGgbbUfAkMm2k4JQIkMXmlHrs24bnSa+CxNeC4eL7cFWZHgLxn6pBfqRCijsCbLpzUhlIJKMMxv2WB0TtHpezD9oUX1/9K7rC3RB4EcKmZ3vDWSsR4UBn9aVCZkQBnr+hfk39lj+Hk2qAMGloVFD0bM10j1Hhv5uMaT8lcClWK/TCcgKH8NQF3hZDqX8YADCYczvZ7B3hA+xpAZwOOZKChOv5Y2ABduD8KPcV6Uc1VLO6+xMlkDZc0MB6HkYlGZSbeMkstgPo+275SKHWVJ7B2nWMvOAyOtjU5OqHwYoNrsCX1TP380DUhQqqAqjzqDP8C0z76Gj root@vm
EOT
}


# We have [F0 F1 S0 S S1 S2 S3 S4 S5 S6 P0 P1 P2 E0 DC0]
# for demo purpose we pick S0 plan, we need to apply for the service to be enabled.
variable "sku" {
  type        = string
  description = "The sku name of the Azure Cognitive Services server to create. Choose from: [F0 F1 S0 S S1 S2 S3 S4 S5 S6 P0 P1 P2 E0 DC0]"
  default     = "S0"
}

variable "iac_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}
variable "iac_kv" {
  type        = string
  description = "The name of the key vault in which the secrets will be stored."
}
variable "iac_st" {
  type        = string
  description = "The name of the storage account in which the Terraform state will be stored."
}

variable "workload" {
  type        = string
  description = "The name of the workload to be deployed."
  default     = "project"
}

variable "app_vnet" {
  type        = string
  description = "The name of the virtual network in which the resources will be created."
}

variable "app_rg" {
  type        = string
  description = "The name of the resource group in which the resources will be created."
}
variable "app_vm" {
  type        = string
  description = "The name of the virtual machine to be created."
  default     = null
}
variable "app_vm_number" {
  type        = number
  description = "The number of virtual machines to be created."
  default     = 1
}
variable "app_vm_size" {
  type        = string
  description = "The size of the virtual machine to be created."
  default     = "Standard_D2s_v3"
}

variable "app_snet" {
  type        = string
  description = "The name of the subnet in which the resources will be created."
}
variable "db_snet" {
  type        = string
  description = "The name of the DB subnet in which the resources will be created."
}
variable "app_vnet_rg" {
  type        = string
  description = "The name of the resource group in which the virtual network is located."
}
variable "app_remote_group" {
  type        = list(string)
  description = "The list of groups that will have remote access to the resources."
  default     = ["BA-G-Azure-Owner-F"]
}
variable "app_admin_group" {
  type        = list(string)
  description = "The list of groups that will have administrative access to the resources."
  default     = ["BA-G-Azure-Owner-F"]
}
variable "app_user_group" {
  type        = list(string)
  description = "The list of groups that will have reader access to the resources."
  default     = ["BA-G-Azure-Owner-F"]
}
variable "bastion_resource_name" {
  type        = string
  description = "Optional Bastion host name that receives Network Contributor RBAC for app_admin_group and app_user_group."
  default     = "bas-net-cc-prd"
}
variable "bastion_resource_group_name" {
  type        = string
  description = "Resource group containing bastion_resource_name."
  default     = "rg-ba-cc-prod-hub-network"
}
variable "app_ad_group" {
  type        = string
  description = "The name of the group that will have reader access to the resources."
  default     = "BA-G-Azure-Owner-F"
}
variable "app_rgadmin_group" {
  type        = string
  description = "The name of the group that will have administrative access to the resources."
  default     = "BA-G-Azure-Owner-F"
}
variable "disksize" {
  type        = number
  description = "The size of the disk to be attached to the virtual machine."
  default     = 0
}
variable "app_sqlmi" {
  type        = string
  description = "The name of the Azure SQL Managed Instance to be created."
}
variable "app_sqlmi_db" {
  type        = string
  description = "The name of the Azure SQL Managed Database to be created."
}
variable "app_sqlmi_rg" {
  type        = string
  description = "The rg name of the Azure SQL Managed Database to be created."
}

variable "app_sqlserver_name" {
  type        = string
  description = "The name of the Azure SQL Server to be created."
}

variable "app_sqldb_name" {
  type        = string
  description = "The name of the Azure SQL db inside the server to be created.."
}



variable "sql_ad_group" {
  type        = string
  description = "The name of the group that will have admin access to the SQL server."
  default     = "BA-G-Azure-Owner-F"
}
variable "sql_ad_group_id" {
  type        = string
  description = "The id of the group that will have admin access to the SQL server."
  default     = "962b2502-5355-48bd-a33e-9280db2ac892"
}

variable "public_network_enabled" {
  type    = bool
  default = false
}
variable "AADLoginForLinux" {
  type    = bool
  default = true
}

variable "vsts_configuration" {
  description = "Azure DevOps repo settings for ADF"
  type = object({
    account_name         = string # ADO organization name
    project_name         = string # ADO project
    repository_name      = string
    branch_name          = string
    root_folder          = string # e.g. "/"
    tenant_id            = string # your AAD tenant GUID
    collaboration_branch = optional(string)
  })
  default = {
    account_name    = ""
    project_name    = ""
    repository_name = ""
    branch_name     = ""
    root_folder     = "/"
    tenant_id       = ""
  }
}

variable "self_hosted_integration_runtime_enabled" {
  type        = bool
  description = "Self Hosted Integration runtime"
  default     = false
}

variable "enable_private_endpoint" {
  description = "Whether to enable private endpoint for SQL Server"
  type        = bool
  default     = true
}
variable "private_endpoint_subnet_id" {
  description = "Subnet ID for the private endpoint"
  type        = string
  default     = ""
}
