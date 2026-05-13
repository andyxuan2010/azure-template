provider "azurerm" {
  features {}
}

variables {
  display_name               = "Platform Landing Zone"
  name                       = "plz-terraform-plan"
  parent_management_group_id = null
  subscription_ids           = []
}

run "plan" {
  command = plan
}
