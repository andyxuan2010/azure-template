provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  server_name         = "sql-iactest-prod-001"
  database_name       = "sqldb-iactest-prod-001"
  max_size_gb         = 10
  server_version      = "12.0"
  collation           = "SQL_Latin1_General_CP1_CI_AS"
  zone_redundant      = false
  admin_username      = "sqladminuser"
  admin_password      = "TerraformLiveTest-ChangeMe123!"
  ad_admin_login_name = "BA-G-Azure-Owner-F"
  ad_admin_object_id  = "7a958d36-a182-451e-8012-4e8fe9386dc7"
  sku_name            = "S0"
  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
  app_env             = "prod"
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
  app_admin_group               = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group                = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_private_endpoint       = false
  private_endpoint_subnet_id    = ""
  public_network_access_enabled = false
  minimum_tls_version           = "1.2"
  backup_retention_days         = 7
  enable_long_term_retention    = false
  long_term_retention_policy    = {}
  enable_threat_detection       = false
  enable_audit                  = false
  audit_retention_days          = 30
  enable_diagnostics            = false
}

run "apply" {
  command = apply
}
