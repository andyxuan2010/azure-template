# Basic Policy Definition

Creates an audit policy definition without an assignment.

This example is independently initializable. Review policy aliases and effects against the target Azure environment before apply.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

Policy definitions and assignments have no charge. Effects such as `deployIfNotExists` and remediation tasks can create billable resources. Enforcement can block or modify deployments. A management group assignment applies to every descendant subscription.
