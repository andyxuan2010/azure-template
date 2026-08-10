# Generated SQL Managed Instance Database Name

Creates a database named `sqmidb-<workload>-<environment>-<instance>` when neither `name` nor the deprecated `app_sqlmi_db` alias is set.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, ensure the generated name is stable and does not collide with an existing database on the parent instance.
