# Firewall Egress Route Table

Sends `0.0.0.0/0` from existing workload subnets to an Azure Firewall or network virtual appliance private IP.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide the real firewall IP and subnet IDs, confirm appliance health and IP forwarding, and test return routing. This example does not create or configure the firewall.
