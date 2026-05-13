locals {
  merged_tags = merge(
    var.tags,
    {
      module = "firewall"
    }
  )

  public_ip_name       = trimspace(var.public_ip_name) != "" ? var.public_ip_name : "${var.name}-pip"
  firewall_policy_name = trimspace(var.firewall_policy_name) != "" ? var.firewall_policy_name : "${var.name}-policy"
}
