# Self-hosted Integration Runtime VM

Creates a private Windows VM, enables VM Run Command bootstrap, and grants its managed identity Data Factory Contributor for SHIR installation and registration.

The shared bootstrap assets and Key Vault registration secret must exist. Validate outbound connectivity to required Data Factory endpoints, the breadth of Data Factory Contributor, and VM costs before applying.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```
