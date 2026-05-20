provider "azurerm" {
  features {}
}

provider "azuread" {}

variables {
  name                = "asp-iactest-prod-001"
  app_env             = "prod"
  resource_group_name = "rg-ba-eus-prd-shared-management"
  location            = "eastus"
  os_type             = "Linux"
  sku_name            = "P1v3"
  app_admin_group     = []
  app_user_group      = []
  enable_diagnostics  = false

  tags = {
    Environment = "Production"
    Owner       = "CCOE"
    IaC         = "Terraform"
  }
}

run "plan" {
  command = plan

  assert {
    condition     = output.name == var.name
    error_message = "App Service Plan name output did not match input."
  }

  assert {
    condition     = output.tags.module == "appserviceplan"
    error_message = "App Service Plan tags did not include the module marker."
  }

  assert {
    condition     = output.autoscale_config == null
    error_message = "Autoscale config should be null when autoscale is disabled."
  }
}

run "plan_autoscale" {
  command = plan

  variables {
    name                = "asp-iactest-prod-001"
    app_env             = "prod"
    resource_group_name = "rg-ba-eus-prd-shared-management"
    location            = "eastus"
    os_type             = "Linux"
    sku_name            = "P1v3"
    worker_count        = 1
    enable_autoscale    = true
    autoscale_enabled   = true

    autoscale_default_capacity = 2
    autoscale_min_capacity     = 1
    autoscale_max_capacity     = 5
    enable_memory_autoscale    = true

    autoscale_notifications = {
      email = {
        custom_emails = ["ops@example.com"]
      }
      webhooks = [
        {
          service_uri = "https://hooks.example.com/autoscale"
          properties = {
            severity = "info"
          }
        }
      ]
    }

    autoscale_custom_rules = [
      {
        metric_name = "HttpQueueLength"
        operator    = "GreaterThan"
        threshold   = 100
        direction   = "Increase"
        value       = 1
      }
    ]

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.autoscale_config.default_capacity == 2
    error_message = "Autoscale default capacity output did not match input."
  }

  assert {
    condition     = output.autoscale_config.custom_rule_count == 1
    error_message = "Autoscale custom rule count output did not match input."
  }
}

run "plan_zone_balanced_premium" {
  command = plan

  variables {
    name                            = "asp-iactest-prod-001"
    app_env                         = "prod"
    resource_group_name             = "rg-ba-eus-prd-shared-management"
    location                        = "eastus"
    os_type                         = "Linux"
    sku_name                        = "P1v4"
    worker_count                    = 3
    zone_balancing_enabled          = true
    premium_plan_auto_scale_enabled = true

    tags = {
      Environment = "Production"
      Owner       = "CCOE"
      IaC         = "Terraform"
    }
  }

  assert {
    condition     = output.zone_balancing_enabled == true
    error_message = "Zone balancing output did not reflect the requested configuration."
  }

  assert {
    condition     = output.premium_plan_auto_scale_enabled == true
    error_message = "Premium plan auto scale output did not reflect the requested configuration."
  }
}
