terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

provider "azurerm" {
  features {}
}

module "policy" {
  source = "../.."

  name         = var.name
  display_name = "Require Owner tag"
  description  = "Audits resources that do not include the Owner tag."
  policy_rule = jsonencode({
    if = {
      field  = "tags['Owner']"
      exists = "false"
    }
    then = {
      effect = "audit"
    }
  })
  metadata = jsonencode({
    category = "Tags"
  })
}
