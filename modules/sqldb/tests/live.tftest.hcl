provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  sql_server_name    = "sql-iactest-prod-001"
  sql_database_name  = "sqldb-iactest-prod-001"
  sql_max_size_gb    = 10
  sql_server_version = "12.0"
  sql_collation      = "SQL_Latin1_General_CP1_CI_AS"
  sql_zone_redundant = false
  sql_admin_username = "sqladminuser"
  sql_admin_password = "TerraformLiveTest-ChangeMe123!"
  sql_ad_admin       = "BA-G-Azure-Owner-F"
  sql_ad_admin_id    = "7a958d36-a182-451e-8012-4e8fe9386dc7"
  sql_sku_name       = "S0"
  sql_rg_name        = "rg-ba-eus-prd-shared-management"
  location           = "eastus"
  app_env            = "prod"
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
  app_admin_group            = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group             = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_private_endpoint    = false
  private_endpoint_subnet_id = ""
  public_network_enabled     = false
  sql_minimum_tls_version    = "1.2"
  backup_retention_days      = 7
  enable_long_term_retention = false
  long_term_retention_policy = {}
  enable_threat_detection    = false
  enable_audit               = false
  audit_retention_days       = 30
  enable_diagnostics         = false
}

run "apply" {
  command = apply
}
