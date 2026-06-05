terraform {
  required_version = ">=1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0"
    }
    azapi = {
      source = "Azure/azapi"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">= 3.0"
    }
    msgraph = {
      source  = "microsoft/msgraph"
      version = ">= 0.3"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }

  backend "azurerm" {
    subscription_id      = "1ec5edd4-5654-4246-8027-b29ef63b3393"
    tenant_id            = "d5b038fb-4b39-41cc-8a10-fba75212180b"
    resource_group_name  = "rg-ccoe-iac-cc-dev"
    storage_account_name = "stccoeiacccdev"
    container_name       = "terraform"
    key                  = "template/terraform.tfstate"
  }


  # backend "local" {
  #   path = "terraform.tfstate"
  # }

}

provider "azurerm" {
  subscription_id = "1ec5edd4-5654-4246-8027-b29ef63b3393"
  features {}
}

provider "azurerm" {
  subscription_id = "1ec5edd4-5654-4246-8027-b29ef63b3393"
  features {}
  alias = "prod"
}

provider "azuread" {}

provider "msgraph" {}

# data "azurerm_client_config" "current" {}
# #data.azurerm_client_config.current.client_id
data "azurerm_subscriptions" "available" {}
# #data.azurerm_subscriptions.available.subscriptions
