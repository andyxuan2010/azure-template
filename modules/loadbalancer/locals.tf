locals {
  tags = merge(
    var.tags,
    {
      module  = "loadbalancer"
      app_env = var.app_env
    }
  )
}
