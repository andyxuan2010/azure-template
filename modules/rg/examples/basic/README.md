# Basic Resource Group

Creates an explicitly named resource group with caller-controlled tags.

Use explicit names for long-lived environments and pass the outputs to downstream modules.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

A resource group has no charge. The lock and role assignments in this example are also free. Role assignments grant access and a delete lock blocks deletion until it is removed.
