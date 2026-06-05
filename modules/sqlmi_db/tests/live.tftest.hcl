provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  app_sqlmi          = "sqlmi-gen-cc-001"
  app_sqlmi_db       = "sqlmidb-iactest-cc-001"
  app_sqlmi_rg       = "rg-sharedservice-cc-prod"
  app_admin_group    = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group     = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_diagnostics = false
}

run "apply" {
  command = apply
}
