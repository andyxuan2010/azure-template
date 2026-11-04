module "bastion" {
  source = "../../"

  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.subnet_id
  sku                 = var.sku

  workload = var.workload
  app_env  = var.app_env
  tags     = var.tags
}
