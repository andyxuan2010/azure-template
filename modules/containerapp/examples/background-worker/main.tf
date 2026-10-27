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

module "worker" {
  source = "../.."

  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  container_app_environment_id  = var.container_app_environment_id
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}

  identity_type = "UserAssigned"
  identity_ids  = [var.worker_identity_id]
  min_replicas  = 0
  max_replicas  = 20

  containers = [{
    name   = "worker"
    image  = var.container_image
    cpu    = 0.5
    memory = "1Gi"
    env = [{
      name  = "QUEUE_NAME"
      value = var.queue_name
    }]
  }]

  custom_scale_rules = [{
    name             = "storage-queue"
    custom_rule_type = "azure-queue"
    identity_id      = var.worker_identity_id
    metadata = {
      accountName = var.storage_account_name
      queueName   = var.queue_name
      queueLength = "10"
    }
  }]

  tags = {
    Environment = "prod"
    Workload    = "queue-worker"
    ManagedBy   = "Terraform"
  }
}
