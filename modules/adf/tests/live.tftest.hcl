provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  location                = "canadacentral"
  environment             = "prod"
  project                 = "iactest"
  resource_group          = "rg-ba-eus-prd-shared-management"
  iac_rg                  = "rg-ccoe-iac-cc-prod"
  iac_kv                  = "kv-ccoe-eus-prod"
  iac_st                  = "stccoeiacprod"
  app_rg                  = "rg-ba-eus-prd-shared-management"
  app_snet                = "snet-ba-cc-prod-hub-sysmgmt"
  app_vnet_rg             = "rg-ba-eus-prod-hub-network"
  app_vnet                = "vnet-ba-eus-prod-hub"
  app_vm                  = "azuwiccoejmp001"
  app_env                 = "prod"
  custom_adf_name         = "adf-cc-iactest-prod-001"
  custom_default_ir_name  = "ir-iactest-prod-001"
  custom_diagnostics_name = null
  custom_shir_name        = "shir-iactest-prod-001"
  tags = {
    resourceType = "ADF"
  }
  public_network_enabled                  = false
  managed_virtual_network_enabled         = false
  cleanup_enabled                         = true
  compute_type                            = "General"
  core_count                              = 8
  permissions                             = []
  time_to_live_min                        = 15
  virtual_network_enabled                 = false
  self_hosted_integration_runtime_enabled = false
  analytics_destination_type              = "Dedicated"
  managed_private_endpoint                = []
  global_parameter                        = []
  app_admin_group                         = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                          = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  vsts_configuration = {
    account_name         = ""
    project_name         = ""
    repository_name      = ""
    branch_name          = ""
    root_folder          = "/"
    tenant_id            = ""
    collaboration_branch = "main"
  }
  enable_private_endpoint              = false
  private_dns_zone_id                  = ""
  private_dns_zone_name                = "privatelink.datafactory.azure.net"
  private_dns_zone_resource_group_name = ""
}

run "apply" {
  command = apply
}
