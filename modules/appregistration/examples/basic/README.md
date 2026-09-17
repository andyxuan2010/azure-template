# Basic App Registration Example

Creates a single-tenant Microsoft Entra application and service principal without a client secret.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

Planning and applying use the configured tenant. Applying changes tenant directory state but creates no Azure billing resource. The execution identity needs application-creation permission; review tenant naming, ownership, consent, and deletion policy first.
