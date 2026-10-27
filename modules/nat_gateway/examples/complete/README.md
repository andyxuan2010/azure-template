# StandardV2 NAT Gateway Example

Associates a StandardV2 NAT Gateway with caller-owned StandardV2 static IPv4 public IPs and existing subnets in one VNet. StandardV2 is zone-redundant by default, so this example does not set `zones`.

Set `resource_group_name`, `location`, `subnet_ids`, and `public_ip_address_ids` in a local `terraform.tfvars` file before planning. Check that public IPs match the gateway SKU and region. Review the effect on all associated subnets before apply; a gateway and its public IPs have ongoing charges.
