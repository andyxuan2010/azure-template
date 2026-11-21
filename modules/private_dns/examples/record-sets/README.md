# Private Record Sets

Creates IPv4, IPv6, CNAME, and TXT record sets in one internal Private DNS zone.

Use this pattern for centrally owned records that are not also managed by a Private Endpoint DNS zone group.

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
