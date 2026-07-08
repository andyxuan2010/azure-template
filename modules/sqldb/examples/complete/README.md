# SQL Database Complete Example

This example shows a small public demo database using the lowest-cost `Basic` SKU. It is intentionally not a production pattern.

For production, prefer the private endpoint examples in [../../EXAMPLES.md](../../EXAMPLES.md).

## Usage

```powershell
terraform init
terraform plan -var="sql_admin_password=<secure-password>" -var="sql_admin_group_object_id=<entra-object-id>"
```

Use Key Vault or a secure variable store for real credentials.
