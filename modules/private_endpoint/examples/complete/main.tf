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

provider "azurerm" {
  alias = "prod"

  features {}
}

module "private_endpoint" {
  source = "../.."

  providers = {
    azurerm      = azurerm
    azurerm.prod = azurerm.prod
  }

  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  subnet_id                       = var.subnet_id
  private_connection_resource_id  = var.private_connection_resource_id
  subresource_names               = [var.subresource_name]
  private_service_connection_name = "psc-${var.name}"
  is_manual_connection            = true
  request_message                 = var.request_message
  custom_network_interface_name   = "nic-${var.name}"

  private_dns_zone_group_name = "service"
  private_dns_zone_ids        = var.private_dns_zone_ids

  ip_configurations = [{
    name               = "primary"
    private_ip_address = var.private_ip_address
    subresource_name   = var.subresource_name
    member_name        = var.member_name
  }]

  inherited_resource_group_tags = var.inherited_resource_group_tags
  tags = {
    DataClassification = "Confidential"
  }
}
