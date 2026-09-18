# Complete SQL Managed Instance Database

Creates one managed database with Log Analytics diagnostics and optional control-plane RBAC groups at database and parent-instance scopes.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide the existing Managed Instance and workspace, confirm role-assignment ownership, and configure SQL users separately. Database usage consumes parent-instance capacity.
