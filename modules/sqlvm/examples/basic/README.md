# Basic SQL VM

Creates one private SQL Server VM with the module's default SQL image, PAYG license, and data/log/TempDB disks.

Supply an existing resource group, subnet, and protected administrator credentials. The example can incur VM, SQL licensing, and managed-disk charges and creates real resources when applied.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
