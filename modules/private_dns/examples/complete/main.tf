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

  resource_group_name           = var.resource_group_name
  inherited_resource_group_tags = var.inherited_resource_group_tags

  zones = {
    "privatelink.vaultcore.azure.net" = {
      vnet_links = {
        hub = {
          virtual_network_id = var.virtual_network_id
        }
      }
      a_records = {
        shared_vault = {
          ttl     = 300
          records = [var.key_vault_private_ip]
        }
      }
    }
    "privatelink.blob.core.windows.net" = {
      vnet_links = {
        hub = {
          virtual_network_id = var.virtual_network_id
        }
      }
      txt_records = {
        ownership = {
          ttl     = 300
          records = ["owner=platform-dns"]
        }
      }
    }
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
