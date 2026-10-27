# Complete Route Table

Creates a production-oriented route table with multiple routes, caller-controlled BGP propagation, and multiple subnet associations.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, replace the example address spaces and appliance IP, provide `resource_group_name` and `subnet_ids`, and verify forward and return routes. Apply routing changes in stages because an incorrect route can immediately interrupt access.

## Cost and risk

- Cost: route tables, user-defined routes and subnet associations are not billed. Any firewall or virtual appliance used as the next hop (default `10.0.0.4`) is billed separately and is not created here.
- Risk: the associations apply immediately to every subnet in `subnet_ids`. The default `0.0.0.0/0` route to a `VirtualAppliance` pulls all internet-bound traffic through that IP, which breaks connectivity if the appliance is absent, not forwarding, or lacks return routes. It also overrides the system default internet route.
- Risk: the `10.20.0.0/16` `VnetLocal` route is more specific than the default and keeps that range local. Set `disable_bgp_route_propagation = true` to suppress routes learned from gateways; that can cut on-premises reachability. Subnet associations are managed here, so another route table already bound to a subnet is replaced.
