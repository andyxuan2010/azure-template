provider "azurerm" {
  features {}
}

variables {
  name                = "nsg-iactest-${formatdate("MMDDhhmmss", timestamp())}"
  resource_group_name = "rg-ccoe-iac-cc-dev"
  location            = "canadacentral"
}

run "apply" {
  command = apply

  variables {
    name                = var.name
    resource_group_name = var.resource_group_name
    location            = var.location
    security_rules = {
      allow_https_in = {
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "443"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        description                = "Allow HTTPS inbound."
      }
    }
    subnet_ids            = []
    network_interface_ids = []
    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.name == var.name
    error_message = "NSG test name was not propagated to the module."
  }
}
