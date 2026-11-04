module "frontdoor" {
  source = "../../"

  name                = "afd-platform-prod-001"
  endpoint_name       = "afd-platform-prod-001"
  resource_group_name = var.resource_group_name
  origin_hostname     = var.origin_hostname
  sku_name            = "Premium_AzureFrontDoor"

  private_link = {
    private_link_target_id = var.origin_resource_id
    location               = var.origin_private_link_region
    target_type            = "sites"
    request_message        = "Approve Azure Front Door access for the production application."
  }

  workload = "platform"
  app_env  = "prod"
  tags     = var.tags
}
