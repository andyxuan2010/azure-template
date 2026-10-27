module "nat_gateway" {
  source = "../../"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_ids          = var.subnet_ids
  sku_name            = "StandardV2"

  public_ip_address_ids   = var.public_ip_address_ids
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  workload                = var.workload
  app_env                 = var.app_env
  tags                    = var.tags
}
