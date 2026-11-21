module "api_management" {
  source = "../../"

  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Developer_1"

  workload                      = var.workload
  app_env                       = var.app_env
  inherit_resource_group_tags   = false
  inherited_resource_group_tags = {}
  tags                          = var.tags
}
