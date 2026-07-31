# Basic Storage Account

Creates one private-by-default Storage account with anonymous access disabled, OAuth preferred, TLS 1.2, and deny-by-default network rules.

No data-plane access path is created. Add approved private connectivity before using the account. Automatic broad role grants to the Terraform identity are disabled in this example; permissions must be managed separately.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
