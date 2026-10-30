# Basic Private Endpoint

Creates a Private Endpoint from direct subnet, target resource, and Private DNS zone IDs.

Direct IDs are recommended when dependencies are produced by the same Terraform composition.

## Usage

Run from this directory. `init` and `validate` need no Azure access; `plan` authenticates with the default Azure credentials.

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=<resource-group-name>" `
  -var="subnet_id=<subnet-id>" `
  -var="private_connection_resource_id=<private-connection-resource-id>"
```

## Cost and risk

Each private endpoint is billed per hour and per GB of data processed, and a linked Private DNS zone group may add zone charges. Apply creates a network interface in the subnet and may need target-service approval before traffic flows. Destroying an endpoint interrupts private access to the target.
