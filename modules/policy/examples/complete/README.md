# Complete Resource Group Assignment

Creates a parameterized tag policy and assigns it to a resource group with an exclusion, non-compliance message, metadata, and system-assigned identity.

The example starts with enforcement disabled. Grant any remediation permissions separately before using `modify` or `deployIfNotExists` effects.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_id=<resource-group-id>"
```

## Cost and risk

Policy definitions and assignments have no charge. Effects such as `deployIfNotExists` and remediation tasks can create billable resources. Enforcement can block or modify deployments. A management group assignment applies to every descendant subscription.
