provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  location                       = "canadacentral"
  app_env                        = "prod"
  AADLoginForWindows             = true
  disksize                       = 100
  app_vm_number                  = 3
  enable_zone_spread             = true
  availability_zones             = ["1", "2", "3"]
  app_vm_size                    = "Standard_B1s"
  iac_rg                         = "rg-ccoe-iac-cc-prod"
  iac_kv                         = "kv-ccoe-cc-prod"
  iac_st                         = "stccoeiacprod"
  app_rg                         = "rg-ccoe-iac-cc-dev"
  app_snet                       = "snet-ba-cc-prod-hub-sysmgmt"
  app_vnet_rg                    = "rg-ba-cc-prod-hub-network"
  app_vnet                       = "vnet-ba-cc-prod-hub"
  app_vm                         = "azuwiiactest"
  domain                         = "2join.us"
  enable_domain_join             = false
  enable_custom_script_extension = true
  app_remote_group               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_admin_group                = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                 = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  vm_remote_group                = "7a958d36-a182-451e-8012-4e8fe9386dc7"
  vm_admin_group                 = "7a958d36-a182-451e-8012-4e8fe9386dc7"
  public_network_enabled         = false
  enable_shir                    = false
  tags = {
    resourceType = "WINVM"
  }
  enable_diagnostics = false
  adf_id             = null
}

run "apply" {
  command = apply
}
