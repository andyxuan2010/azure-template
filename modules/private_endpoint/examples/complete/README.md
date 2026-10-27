# Complete Private Endpoint

Creates a manually approved Private Endpoint with a custom service connection name, custom NIC name, DNS zone group, and static IP configuration.

Confirm that the target service supports the requested static-IP member and subresource values before apply.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=<resource-group-name>" `
  -var="subnet_id=<subnet-id>" `
  -var="private_connection_resource_id=<private-connection-resource-id>" `
  -var="private_dns_zone_ids=<private-dns-zone-ids>"
```

## Cost and risk

Each private endpoint is billed per hour and per GB of data processed, and a linked Private DNS zone group may add zone charges. Apply creates a network interface in the subnet and may need target-service approval before traffic flows. Destroying an endpoint interrupts private access to the target.
