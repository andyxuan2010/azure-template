# Basic SQL Managed Instance Database

Creates one explicitly named database on an existing SQL Managed Instance.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, supply the existing instance name and resource group and confirm backup and data-loss controls. The database consumes capacity on the billable parent instance.
