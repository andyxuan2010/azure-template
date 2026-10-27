# Generated SQL Managed Instance Database Name

Creates a database named `sqmidb-<workload>-<environment>-<instance>` when neither `name` nor the deprecated `app_sqlmi_db` alias is set.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, ensure the generated name is stable and does not collide with an existing database on the parent instance.

## Cost and risk

- Billing: only the managed database is created. It has no extra charge of its own and uses vCore and storage capacity of the existing Managed Instance, which is billed per vCore-hour and per GB of storage.
- Risk: the name is generated from workload, environment and instance, so changing any of them renames the database, which Terraform treats as replacement and deletes the data. Apply fails if a database with that name already exists on the instance.
