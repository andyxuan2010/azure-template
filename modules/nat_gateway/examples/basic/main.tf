module "nat_gateway" {
  source = "../../"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_ids          = var.subnet_ids
  sku_name            = "Standard"

  workload = var.workload
  app_env  = var.app_env
  tags     = var.tags
}
