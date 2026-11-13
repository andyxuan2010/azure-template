# Complete Private DNS Configuration

Creates Key Vault and Blob Private DNS zones, links both zones to an existing VNet, and adds representative records.

Private endpoint zone groups normally own endpoint A records. Use explicit records only when centralized DNS ownership is intentional.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=<resource-group-name>" `
  -var="virtual_network_id=<virtual-network-id>"
```

## Cost and risk

Azure bills each Private DNS zone per month and per million DNS queries. Linking a zone to a virtual network changes name resolution for that network. Duplicate zone names across resource groups can split resolution.
