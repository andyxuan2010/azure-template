provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  name                       = "asp-iactest-prod-python-001"
  resource_group_name        = "rg-ba-eus-prd-shared-management"
  location                   = "canadacentral"
  os_type                    = "Windows"
  sku_name                   = "B1"
  app_admin_group            = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  app_user_group             = ["7a958d36-a182-451e-8012-4e8fe9386dc7"]
  enable_diagnostics         = false
  log_analytics_workspace_id = ""
  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "apply" {
  command = apply
}
