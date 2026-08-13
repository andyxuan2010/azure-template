# Integration plan tests. These runs configure real providers but do not apply resources.

provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  name           = "iactest"
  app_env        = "prod"
  location       = "canadacentral"
  resource_group = "rg-ccoe-iac-cc-dev"

  identity_type                            = "SystemAssigned"
  public_network_enabled                   = false
  managed_virtual_network_enabled          = true
  create_default_azure_integration_runtime = true
  app_admin_group                          = []
  app_user_group                           = []
  permissions                              = []
  enable_diagnostics                       = false
  log_analytics_workspace                  = {}
  managed_private_endpoint                 = []
  global_parameter                         = []
  enable_private_endpoint                  = false
  self_hosted_integration_runtime_enabled  = false

  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "plan" {
  command = plan

  assert {
    condition     = output.name == "iactest"
    error_message = "ADF explicit name override was not preserved."
  }

  assert {
    condition     = !contains(keys(output.merged_tags), "module") && !contains(keys(output.merged_tags), "name")
    error_message = "ADF merged tags should not include module-generated module or name tags."
  }

  assert {
    condition     = output.diagnostics_enabled == false
    error_message = "ADF diagnostics should be disabled when no workspace mapping is provided."
  }
}

run "plan_private_endpoint" {
  command = plan

  variables {
    name           = "iactest"
    app_env        = "prod"
    location       = "canadacentral"
    resource_group = "rg-ccoe-iac-cc-dev"

    identity_type                   = "SystemAssigned"
    managed_virtual_network_enabled = true
    app_admin_group                 = []
    app_user_group                  = []
    permissions                     = []

    enable_private_endpoint    = true
    private_endpoint_subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-example/subnets/snet-private-endpoints"
    private_dns_zone_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-dns/providers/Microsoft.Network/privateDnsZones/privatelink.datafactory.azure.net"

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.name == "iactest"
    error_message = "ADF private endpoint plan did not preserve the explicit name override."
  }
}

run "plan_managed_network" {
  command = plan

  variables {
    name           = "iactest"
    app_env        = "prod"
    location       = "canadacentral"
    resource_group = "rg-ccoe-iac-cc-dev"

    identity_type                   = "SystemAssigned"
    managed_virtual_network_enabled = true
    app_admin_group                 = []
    app_user_group                  = []
    permissions                     = []

    managed_private_endpoint = [
      {
        name               = "storage-blob"
        target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-data/providers/Microsoft.Storage/storageAccounts/stexample001"
        subresource_name   = "blob"
      }
    ]

    global_parameter = [
      {
        name  = "environment"
        type  = "String"
        value = "prod"
      }
    ]

    github_configuration = {
      account_name       = "CCOE-Azure-Terraform"
      repository_name    = "azure-template"
      branch_name        = "main"
      git_url            = "https://github.com/CCOE-Azure-Terraform/azure-template"
      root_folder        = "/"
      publishing_enabled = true
    }

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = contains(keys(output.managed_private_endpoint_ids), "storage-blob")
    error_message = "ADF managed private endpoint output was not keyed by the requested endpoint name."
  }
}

run "plan_additional_role_assignment" {
  command = plan

  variables {
    name           = "iactest"
    app_env        = "test"
    location       = "canadacentral"
    resource_group = "rg-ccoe-iac-cc-dev"

    app_admin_group = []
    app_user_group  = []
    permissions = [
      {
        object_id = "33333333-3333-3333-3333-333333333333"
        role      = "Data Factory Contributor"
      }
    ]
  }

  assert {
    condition     = length(output.additional_role_assignment_ids) == 1
    error_message = "ADF should create one additional role assignment for a unique object and role pair."
  }
}

run "reject_duplicate_additional_role_assignment" {
  command = plan

  variables {
    permissions = [
      {
        object_id = "33333333-3333-3333-3333-333333333333"
        role      = "Data Factory Contributor"
      },
      {
        object_id = "33333333-3333-3333-3333-333333333333"
        role      = "data factory contributor"
      }
    ]
  }

  expect_failures = [
    var.permissions,
  ]
}
