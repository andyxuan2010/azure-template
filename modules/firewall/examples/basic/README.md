# Basic Azure Firewall Example

Creates a zone-redundant Standard Azure Firewall, one Standard static public IP, and a Standard Firewall Policy with DNS proxy and deny-mode threat intelligence.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-network-dev" `
  -var="azure_firewall_subnet_id=/subscriptions/.../virtualNetworks/vnet-hub-dev/subnets/AzureFirewallSubnet"
```

Azure Firewall is billable while deployed. Confirm the subnet is `/26` or larger and review zone support. This example does not create route tables or allow rules, so no workload traffic is routed or permitted automatically.
