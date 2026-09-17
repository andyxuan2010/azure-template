# Complete Storage Account

Creates a private-by-default Storage account with system identity, a private Blob container, Blob/DFS private endpoints and DNS, and Log Analytics diagnostics.

Run Terraform from a network that can resolve and reach the private data plane before creating containers. Supply matching `blob` and `dfs` zone IDs. Storage, Private Link, DNS, and Log Analytics ingestion can incur charges.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
