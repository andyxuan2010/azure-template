# Basic Private DNS Zone

Creates one Private DNS zone with a single A record.

The resource group must already exist. The example disables resource group tag lookup so all inputs are plan-known.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=<resource-group-name>"
```

## Cost and risk

Azure bills each Private DNS zone per month and per million DNS queries. Linking a zone to a virtual network changes name resolution for that network. Duplicate zone names across resource groups can split resolution.
