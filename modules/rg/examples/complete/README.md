# Complete Resource Group

Creates a production resource group with a deletion lock, Contributor and Reader group shortcuts, an additional conditional role assignment, and operation timeouts.

Object IDs avoid ambiguous Microsoft Entra display-name lookup. Confirm that the executing identity can create RBAC assignments.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="contributor_group_object_id=<contributor-group-object-id>" `
  -var="reader_group_object_id=<reader-group-object-id>" `
  -var="application_principal_id=<application-principal-id>"
```

## Cost and risk

A resource group has no charge. The lock and role assignments in this example are also free. Role assignments grant access and a delete lock blocks deletion until it is removed.
