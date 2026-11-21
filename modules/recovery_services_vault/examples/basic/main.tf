module "recovery_services_vault" {
  source = "../../"

  name                = "rsv-platform-cc-dev-001"
  resource_group_name = var.resource_group_name
  location            = var.location

  storage_mode_type = "ZoneRedundant"
  immutability      = "Unlocked"

  workload = "platform"
  app_env  = "dev"
  tags = {
    Owner       = "CCOE"
    Environment = "dev"
  }
}
