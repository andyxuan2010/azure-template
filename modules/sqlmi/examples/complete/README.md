# Complete SQL Managed Instance

Creates a private General Purpose instance with combined managed identity, Entra administration, diagnostics, and optional control-plane RBAC groups.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, confirm quota, subnet sizing, licensing eligibility, identity permissions, monitoring access, and a maintenance window. This is a high-cost, long-running deployment.
