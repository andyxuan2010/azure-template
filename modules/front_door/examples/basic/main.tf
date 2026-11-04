module "frontdoor" {
  source = "../../"

  name                = "afd-platform-dev-001"
  endpoint_name       = "afd-platform-dev-001"
  resource_group_name = var.resource_group_name
  origin_hostname     = var.origin_hostname
  sku_name            = "Standard_AzureFrontDoor"

  workload = "platform"
  app_env  = "dev"
  tags = {
    Owner       = "CCOE"
    Environment = "dev"
  }
}
