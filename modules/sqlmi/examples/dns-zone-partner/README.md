# SQL Managed Instance DNS-Zone Partner

Creates a Managed Instance that joins the DNS zone of an existing partner instance.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, confirm that the partner ID, region, subnet, lifecycle ownership, and intended failover topology satisfy platform requirements. This example does not create replication or a failover group and incurs substantial Managed Instance cost.
