# Firewall Egress Route Table

Sends `0.0.0.0/0` from existing workload subnets to an Azure Firewall or network virtual appliance private IP.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide the real firewall IP and subnet IDs, confirm appliance health and IP forwarding, and test return routing. This example does not create or configure the firewall.

## Cost and risk

- Cost: the route table, the single route and the subnet associations are not billed. The Azure Firewall or appliance at `firewall_private_ip` is billed separately and is not created here.
- Risk: the `0.0.0.0/0` route to a `VirtualAppliance` is applied to every subnet in `workload_subnet_ids` at once. If the appliance is down, does not forward traffic, or has no return route, workloads lose internet and most outbound access immediately. Test on a single subnet first.
- Risk: BGP propagation stays enabled by default, but the default route still takes priority over a BGP default route for those subnets. Associating replaces any route table already on those subnets.
