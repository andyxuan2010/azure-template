# Basic SQL Managed Instance

Creates a private General Purpose SQL Managed Instance with system-assigned identity in an existing delegated subnet.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide the dedicated subnet, resource group, and administrator password through a secure variable source. Managed Instance deployment and deletion can take hours and incur substantial cost.
