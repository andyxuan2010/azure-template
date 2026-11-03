# Complete Log Analytics Example

Creates a PerGB2018 Log Analytics workspace with 180-day retention and a 10 GB daily ingestion cap. Ingestion is restricted to private links, query stays reachable from the internet, and local (shared-key) authentication is disabled.

Private ingestion needs an Azure Monitor Private Link Scope in the calling root. This example only validates the module interface.

## Usage

```powershell
terraform init -backend=false
terraform validate
```
