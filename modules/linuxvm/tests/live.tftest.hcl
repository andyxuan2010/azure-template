provider "azurerm" {
  features {}
}

variables {
  common_tags = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "environment"                       = "Prod"
    "Infra Availability Classification" = "Bronze"
    "InfraSupport Team"                 = "CCOE"
    "Maintenance Window"                = "CCOE"
    "Project Name"                      = "CCOE INFRA IAC"
    "Project Number"                    = "N/A"
    "RPO-RTO"                           = "48H/24H"
    "Run Cost(Approved Run Budget)-USD" = "100"
  }
  rg_tags = {
    "Application Name"                  = "CCOE INFRA IAC"
    "Application Owner"                 = "CCOE"
    "AppSupport Team"                   = "CCOE"
    "Approval Group"                    = "CCOE"
    "Business Owner"                    = "CCOE"
    "environment"                       = "Prod"
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
  location         = "canadacentral"
  app_env          = "prod"
  workload         = "iactest"
  admin_username   = "azureadmin"
  admin_password   = "TerraformLiveTest-ChangeMe123!"
  admin_ssh_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDpC2+ri1pCn9Q9YE4z9aZ+0fYXYek/okCGcR7qvhvURHlQZ6N34wd3U4lbefrxvXNxPsijmil89qx3ThglAc4cbjcBkjJ9iLUIqF5J76MM4U2rDJUQxSPDMt89Z1geBIdhwCZatjZ1gVmrq8bbJZtxltmShImk21rWAmLFf31dve2gVdmPtaURYlpRoMSb3bUyifoY0+F7W+vDkGKfcOvLrBNDQYMmOJ5x5Meiw3ozrVtV22FeDPzkAIMF6WQrErU67lmAIenC9pvRfMtgOTzGIgwQdZzMK3KZgNjA4f5Xs/tvWocrTEzU8j3JXISMDEm/qhbAdC8C3P4Tjo/csUhF terraform-live-test"
  post_init_script = ""

  # Authentication and identity options
  enable_system_assigned_identity = true
  enable_entra_ssh_login          = false
  enable_domain_join              = false
  enable_zone_spread              = true
  availability_zones              = ["1", "2", "3"]

  # Optional post-bootstrap localization extension
  enable_linux_vm_extension   = false
  localization_container_name = "localization"
  localization_os_script_name = "ubuntu.sh"

  datadog_api_key          = "sample_api_key"
  data_disk_size_gb        = 100
  vm_count                 = 1
  vm_size                  = "Standard_B2s"
  enable_spot_instance     = false
  spot_eviction_policy     = "Deallocate"
  spot_max_bid_price       = -1
  image_publisher          = "Canonical"
  image_offer              = "ubuntu-24_04-lts"
  image_sku                = "server"
  image_version            = "latest"
  iac_rg                   = "rg-ccoe-iac-cc-prod"
  iac_kv                   = "kv-ccoe-cc-prod"
  iac_st                   = "stccoeiacprod"
  resource_group_name      = "rg-ba-cc-prd-shared-management"
  subnet_name              = "snet-ba-cc-prod-hub-sysmgmt"
  vnet_resource_group_name = "rg-ba-cc-prod-hub-network"
  vnet_name                = "vnet-ba-cc-prod-hub"
  vm_name                  = "azuliccoejmp"
  domain                   = "2join.us"
  domain_join_user         = "AERO\\\\b1001332a1"
  domain_join_ou           = "azure"
  app_admin_group          = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group           = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  public_network_enabled   = false
}

run "apply" {
  command = apply
}
