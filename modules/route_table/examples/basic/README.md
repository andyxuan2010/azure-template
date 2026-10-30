# Basic Route Table

Creates a route table with a direct Internet default route and associates one existing subnet.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before plan or apply, provide `resource_group_name` and `subnet_id`, authenticate to Azure, and review whether overriding the subnet's default route is intended. Route tables have no direct hourly charge, but dependent gateways and appliances may be billable.
