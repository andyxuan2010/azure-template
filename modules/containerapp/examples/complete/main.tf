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

module "container_app" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  container_app_environment_id  = var.container_app_environment_id
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  revision_mode          = "Multiple"
  max_inactive_revisions = 5
  revision_suffix        = var.revision_suffix
  identity_type          = "SystemAssigned"
  min_replicas           = 2
  max_replicas           = 10

  secrets = [{
    name                = "api-token"
    key_vault_secret_id = var.key_vault_secret_id
    identity            = "System"
  }]

  containers = [{
    name   = "api"
    image  = var.container_image
    cpu    = 0.5
    memory = "1Gi"
    env = [
      {
        name  = "APP_ENV"
        value = "prod"
      },
      {
        name        = "API_TOKEN"
        secret_name = "api-token"
      }
    ]
  }]

  ingress = {
    external_enabled           = true
    target_port                = 8080
    allow_insecure_connections = false
    traffic_weight = [{
      percentage      = 100
      latest_revision = true
      label           = "stable"
    }]
    ip_security_restrictions = [{
      name             = "corporate-egress"
      action           = "Allow"
      ip_address_range = var.allowed_cidr
      description      = "Replace with a controlled enterprise egress range."
    }]
    cors = {
      allowed_origins = var.allowed_origins
      allowed_methods = ["GET", "POST", "OPTIONS"]
      allowed_headers = ["Authorization", "Content-Type"]
    }
  }

  http_scale_rules = [{
    name                = "http-concurrency"
    concurrent_requests = "50"
  }]

  tags = {
    Environment = "prod"
    Criticality = "High"
    ManagedBy   = "Terraform"
  }
}
