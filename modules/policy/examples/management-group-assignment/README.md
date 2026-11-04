# Management Group Assignment

Creates a custom allowed-locations policy definition at management group scope and assigns it to that management group.

Management group assignments affect descendants. Review the generated plan and begin with non-enforcing behavior where organizational policy requires a staged rollout.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="management_group_id=<management-group-id>"
```

## Cost and risk

Policy definitions and assignments have no charge. Effects such as `deployIfNotExists` and remediation tasks can create billable resources. Enforcement can block or modify deployments. A management group assignment applies to every descendant subscription.
