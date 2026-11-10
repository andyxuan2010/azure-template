output "fortigate" {
  description = "Key active-passive deployment values."
  value = {
    virtual_machine_ids                = module.fortigate.virtual_machine_ids
    private_ip_addresses               = module.fortigate.private_ip_addresses
    internal_load_balancer_id          = module.fortigate.internal_load_balancer_id
    internal_load_balancer_frontend_ip = module.fortigate.internal_load_balancer_frontend_ip
    external_load_balancer_id          = module.fortigate.external_load_balancer_id
    public_frontend_enabled            = module.fortigate.public_frontend_enabled
  }
}
