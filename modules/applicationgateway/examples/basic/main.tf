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

module "application_gateway" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  backend_address_pools = {
    application = {
      ip_addresses = var.backend_ip_addresses
    }
  }

  backend_http_settings = {
    application = {
      port     = 80
      protocol = "Http"
    }
  }

  http_listeners = {
    public_http = {
      frontend_port_name = "http"
      protocol           = "Http"
    }
  }

  request_routing_rules = {
    application = {
      rule_type                  = "Basic"
      http_listener_name         = "public_http"
      backend_address_pool_name  = "application"
      backend_http_settings_name = "application"
      priority                   = 100
    }
  }

  tags = {
    Environment = "dev"
    Owner       = "Platform"
  }
}
