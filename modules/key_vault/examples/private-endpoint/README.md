# Cross-Subscription Private Endpoint Lookup Example

Creates a Key Vault and resolves its existing private endpoint subnet and private DNS zone by name through the `azurerm.prod` provider in a shared-services subscription.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="resource_group_name=rg-orders-prod" `
  -var="shared_services_subscription_id=00000000-0000-0000-0000-000000000000" `
  -var="private_endpoint_vnet_name=vnet-platform-prod" `
  -var="network_resource_group_name=rg-network-prod" `
  -var="dns_resource_group_name=rg-dns-prod"
```

The Terraform identity needs read access to the shared subscription and create access in the workload subscription. Applying creates a billable Key Vault and private endpoint.
