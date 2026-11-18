module "recovery_services_vault" {
  source = "../../"

  name                = "rsv-platform-cc-prod-001"
  resource_group_name = var.resource_group_name
  location            = var.location

  sku                           = "Standard"
  storage_mode_type             = "GeoRedundant"
  cross_region_restore_enabled  = true
  public_network_access_enabled = true
  immutability                  = "Unlocked"

  workload = "platform"
  app_env  = "prod"
  instance = "001"
  tags     = var.tags
}
