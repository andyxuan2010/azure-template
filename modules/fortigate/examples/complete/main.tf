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

module "fortigate" {
  source = "../.."

  architecture                  = "active-passive"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  name_prefix                   = var.name_prefix
  admin_ssh_public_key          = var.admin_ssh_public_key
  availability_zones            = var.availability_zones
  load_balancer_frontend_zones  = var.load_balancer_frontend_zones
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  interfaces = {
    external = {
      role      = "external"
      subnet_id = var.external_subnet_id
      primary   = true
      private_ip_addresses = {
        a = "10.20.0.4"
        b = "10.20.0.5"
      }
    }
    internal = {
      role      = "internal"
      subnet_id = var.internal_subnet_id
      private_ip_addresses = {
        a = "10.20.1.4"
        b = "10.20.1.5"
      }
    }
    ha = {
      role                  = "ha"
      subnet_id             = var.ha_subnet_id
      enabled_architectures = ["active-passive"]
      associate_nsg         = false
      private_ip_addresses = {
        a = "10.20.2.4"
        b = "10.20.2.5"
      }
    }
    management = {
      role                  = "management"
      subnet_id             = var.management_subnet_id
      enabled_architectures = ["active-passive"]
      private_ip_addresses = {
        a = "10.20.3.4"
        b = "10.20.3.5"
      }
    }
  }

  internal_load_balancer = {
    enabled             = true
    interface_name      = "internal"
    frontend_ip_address = "10.20.1.10"
    health_probe_port   = 8008
    enable_ha_ports     = true
    enable_floating_ip  = true
  }

  external_load_balancer = {
    enabled             = true
    interface_name      = "external"
    create_public_ip    = false
    frontend_ip_address = "10.20.0.10"
    health_probe_port   = 8008
    enable_ha_ports     = true
    enable_floating_ip  = true
  }

  tags = {
    Environment = "prod"
    Criticality = "High"
    ManagedBy   = "Terraform"
  }
}
