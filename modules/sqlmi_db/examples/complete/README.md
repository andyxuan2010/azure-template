# Complete SQL Managed Instance Database

Creates one managed database with Log Analytics diagnostics and optional control-plane RBAC groups at database and parent-instance scopes.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide the existing Managed Instance and workspace, confirm role-assignment ownership, and configure SQL users separately. Database usage consumes parent-instance capacity.

## Cost and risk

- Billing: the managed database adds no separate charge here; it consumes storage and compute of the existing parent Managed Instance (billed per vCore-hour and per GB of reserved storage on the instance). Diagnostic settings bill per GB of logs and metrics ingested into the Log Analytics workspace. Role assignments are free.
- Risk: the Contributor assignment on the database and the Reader assignments on the parent instance give the supplied groups control-plane access, and are removed on destroy. Destroying the module deletes the database and its data.
