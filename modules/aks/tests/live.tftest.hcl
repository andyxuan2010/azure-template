provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  resource_group_name                                 = "rg-ba-eus-prd-shared-management"
  location                                            = "eastus"
  name                                                = "aks-iactest-prod-001"
  app_env                                             = "prod"
  dns_prefix                                          = "aks-iactest-prod-001"
  kubernetes_version                                  = null
  sku_tier                                            = "Free"
  automatic_upgrade_channel                           = "patch"
  private_cluster_enabled                             = true
  private_dns_zone_id                                 = ""
  private_dns_zone_name                               = ""
  private_dns_zone_resource_group_name                = ""
  role_based_access_control_enabled                   = true
  azure_rbac_enabled                                  = true
  local_account_disabled                              = true
  oidc_issuer_enabled                                 = true
  workload_identity_enabled                           = true
  key_vault_secrets_provider_enabled                  = true
  key_vault_secrets_provider_secret_rotation_enabled  = true
  key_vault_secrets_provider_secret_rotation_interval = "2m"
  app_admin_group                                     = []
  app_user_group                                      = []
  default_node_pool = {
    name                = "system"
    vm_size             = "Standard_B2ms"
    node_count          = 1
    enable_auto_scaling = false
    zones               = []
    os_disk_size_gb     = 128
    os_sku              = "Ubuntu"
    type                = "VirtualMachineScaleSets"
    vnet_subnet_id      = ""
  }
  network_profile = {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }
  enable_diagnostics           = false
  diagnostic_log_categories    = []
  diagnostic_metric_categories = ["AllMetrics"]
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "apply" {
  command = apply
}
