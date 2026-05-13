# SQL Database Module - Complete Example

This example shows a minimal configuration for the `sqldb` module that provisions:

- An Azure SQL Server
- A single Azure SQL Database

using simple, non-production values.

## Files

- `example.tf` – Example module invocation

## Usage

From the `modules/sqldb/examples/complete` directory:

```bash
terraform init
terraform plan
terraform apply
```

> **Note:** The credentials in `example.tf` (`sql_admin_password`) are hard-coded for demonstration only. For any real environment, move secrets to variables and store them securely (for example in Azure Key Vault and referenced via variables).

