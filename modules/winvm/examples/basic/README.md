# Basic Windows VM

Creates one private Windows VM with Microsoft Entra login, a system-assigned identity, and shared Storage/Key Vault role assignments.

Supply existing network and shared-IaC resources plus protected administrator credentials. Review the built-in Key Vault roles before applying. The example creates billed compute resources.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
