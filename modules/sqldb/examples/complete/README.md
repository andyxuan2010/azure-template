# Complete Azure SQL Database

Creates a private, Entra-only General Purpose database with auditing, diagnostics, long-term immutable backup policy, and optional control-plane RBAC groups.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, verify regional SKU support, backup retention requirements, network and DNS dependencies, monitoring access, and Entra identities. This example creates multiple billable resources and production retention commitments.
