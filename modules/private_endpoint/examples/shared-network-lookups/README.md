# Shared Network Lookups

Creates a Private Endpoint through the default AzureRM provider while resolving its subnet and Private DNS zone by name through `azurerm.prod`.

Configure `azurerm.prod` for the shared connectivity subscription in the consuming stack.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=<resource-group-name>" `
  -var="private_connection_resource_id=<private-connection-resource-id>" `
  -var="virtual_network_name=<virtual-network-name>" `
  -var="virtual_network_resource_group_name=<virtual-network-resource-group-name>" `
  -var="private_dns_zone_resource_group_name=<private-dns-zone-resource-group-name>"
```

## Cost and risk

Each private endpoint is billed per hour and per GB of data processed, and a linked Private DNS zone group may add zone charges. Apply creates a network interface in the subnet and may need target-service approval before traffic flows. Destroying an endpoint interrupts private access to the target.
