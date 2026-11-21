# Complete Role Assignments

Creates assignments at multiple scopes using both direct IDs and name resolution.

Group and role name resolution requires directory and Azure read permissions. Prefer IDs when names are duplicated or custom roles have narrow assignable scopes.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="subscription_id=<subscription-id>" `
  -var="resource_group_id=<resource-group-id>" `
  -var="platform_reader_group_name=<platform-reader-group-name>" `
  -var="contributor_role_definition_id=<contributor-role-definition-id>" `
  -var="application_principal_id=<application-principal-id>"
```

## Cost and risk

Role assignments have no charge. Assignments change access immediately. Review the scope and principal in the plan, and prefer object IDs over names.
