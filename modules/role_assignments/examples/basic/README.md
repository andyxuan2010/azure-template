# Basic Role Assignment

Assigns Reader at an existing resource group to a known principal object ID.

Direct IDs avoid directory and role-name ambiguity.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_id=<resource-group-id>" `
  -var="principal_id=<principal-id>"
```

## Cost and risk

Role assignments have no charge. Assignments change access immediately. Review the scope and principal in the plan, and prefer object IDs over names.
