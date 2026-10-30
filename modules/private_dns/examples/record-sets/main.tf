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

module "private_dns" {
  source = "../.."

  resource_group_name         = var.resource_group_name
  inherit_resource_group_tags = false

  zones = {
    (var.zone_name) = {
      a_records = {
        api = {
          ttl     = 300
          records = ["10.20.1.10"]
        }
      }
      aaaa_records = {
        api = {
          ttl     = 300
          records = ["2001:db8::10"]
        }
      }
      cname_records = {
        service = {
          ttl    = 300
          record = "api.${var.zone_name}"
        }
      }
      txt_records = {
        verification = {
          ttl     = 300
          records = ["verification=platform"]
        }
      }
    }
  }
}
