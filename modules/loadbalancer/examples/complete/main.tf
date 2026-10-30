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

module "load_balancer" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  frontend_ip_configurations = [{
    name                 = "public"
    public_ip_address_id = var.public_ip_address_id
  }]

  backend_address_pools = [{
    name = "application"
  }]

  probes = [{
    name         = "https"
    protocol     = "Https"
    port         = 443
    request_path = "/health"
  }]

  lb_rules = [{
    name                           = "https"
    protocol                       = "Tcp"
    frontend_port                  = 443
    backend_port                   = 443
    frontend_ip_configuration_name = "public"
    backend_address_pool_name      = "application"
    probe_name                     = "https"
    disable_outbound_snat          = true
    enable_tcp_reset               = true
  }]

  outbound_rules = [{
    name                           = "egress"
    backend_address_pool_name      = "application"
    frontend_ip_configuration_name = "public"
    protocol                       = "All"
  }]

  tags = {
    Environment = "prod"
    Owner       = "Network Team"
  }
}
