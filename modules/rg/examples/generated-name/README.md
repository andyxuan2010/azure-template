# Deterministic Generated Name

Creates a resource group named from prefix, workload, environment, location code, and instance.

Random suffixes are disabled so the planned name is predictable: `rg-shared-poc-cc-001`.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan
```

## Cost and risk

A resource group has no charge. The lock and role assignments in this example are also free. Role assignments grant access and a delete lock blocks deletion until it is removed.
