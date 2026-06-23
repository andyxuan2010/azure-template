mock_provider "azurerm" {}

variables {
  resource_group_name  = "rg-network-test"
  location             = "canadacentral"
  name_prefix          = "fgt-test"
  admin_ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK6CeDp5G4Z+b0ocYVn9dOidyafLythOOPrO4Qql8ule terraform-module-validation"

  interfaces = {
    external = {
      role      = "external"
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-external"
      primary   = true
      private_ip_addresses = {
        a = "10.20.0.4"
        b = "10.20.0.5"
      }
    }
    internal = {
      role      = "internal"
      subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-internal"
      private_ip_addresses = {
        a = "10.20.1.4"
        b = "10.20.1.5"
      }
    }
    ha = {
      role                  = "ha"
      subnet_id             = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network-test/providers/Microsoft.Network/virtualNetworks/vnet-test/subnets/snet-ha"
      enabled_architectures = ["active-passive"]
      associate_nsg         = false
      private_ip_addresses = {
        a = "10.20.2.4"
        b = "10.20.2.5"
      }
    }
  }
}

run "single_private_plan" {
  command = plan

  assert {
    condition     = output.architecture == "single"
    error_message = "The default architecture must be single."
  }

  assert {
    condition     = length(output.virtual_machine_names) == 1
    error_message = "Single architecture must create one FortiGate VM."
  }

  assert {
    condition     = output.public_frontend_enabled == false
    error_message = "Public frontend must be disabled by default."
  }
}

run "active_passive_private_load_balancers" {
  command = plan

  variables {
    architecture = "active-passive"

    internal_load_balancer = {
      enabled             = true
      interface_name      = "internal"
      frontend_ip_address = "10.20.1.10"
    }

    external_load_balancer = {
      enabled             = true
      interface_name      = "external"
      create_public_ip    = false
      frontend_ip_address = "10.20.0.10"
    }
  }

  assert {
    condition     = length(output.virtual_machine_names) == 2
    error_message = "Active-passive architecture must create two FortiGate VMs."
  }

  assert {
    condition     = contains(keys(output.private_ip_addresses), "a-ha") && contains(keys(output.private_ip_addresses), "b-ha")
    error_message = "Active-passive architecture should include both HA interfaces."
  }

  assert {
    condition     = output.public_frontend_enabled == false
    error_message = "Private HA load balancers must not create a public frontend."
  }
}

run "active_passive_public_frontend_opt_in" {
  command = plan

  variables {
    architecture = "active-passive"

    external_load_balancer = {
      enabled          = true
      interface_name   = "external"
      create_public_ip = true
    }
  }

  assert {
    condition     = output.public_frontend_enabled == true
    error_message = "Public frontend should only be enabled by explicit opt-in."
  }
}

run "single_with_module_created_subnets" {
  command = plan

  variables {
    create_subnets       = true
    virtual_network_name = "vnet-hub-test"

    interfaces = {
      external = {
        role             = "external"
        subnet_name      = "snet-fortigate-external"
        address_prefixes = ["10.20.0.0/24"]
        primary          = true
        private_ip_addresses = {
          a = "10.20.0.4"
        }
      }
      internal = {
        role             = "internal"
        subnet_name      = "snet-fortigate-internal"
        address_prefixes = ["10.20.1.0/24"]
        private_ip_addresses = {
          a = "10.20.1.4"
        }
      }
    }
  }

  assert {
    condition     = length(output.subnet_ids) == 2
    error_message = "The module-created subnet architecture should expose two subnet IDs."
  }

  assert {
    condition     = output.public_frontend_enabled == false
    error_message = "Creating dedicated subnets must not enable a public frontend."
  }
}
