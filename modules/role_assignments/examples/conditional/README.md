# Conditional Role Assignment

Assigns Storage Blob Data Reader with an Azure RBAC condition that limits access to one container name.

Azure validates condition syntax at apply time. Test the condition against the intended storage data-plane operations before production rollout.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="storage_account_id=<storage-account-id>" `
  -var="principal_id=<principal-id>"
```

## Cost and risk

Role assignments have no charge. Assignments change access immediately. Review the scope and principal in the plan, and prefer object IDs over names.
