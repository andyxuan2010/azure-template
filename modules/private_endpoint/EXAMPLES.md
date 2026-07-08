# Private Endpoint Examples

## Storage Blob Private Endpoint

```hcl
module "storage_blob_private_endpoint" {
  source = "./modules/private_endpoint"

  resource_group_name            = "rg-platform-dev"
  location                       = "canadacentral"
  subnet_id                      = module.vnet.subnet_ids["snet-private-endpoints"]
  private_connection_resource_id = module.storageaccount.id
  subresource_names              = ["blob"]

  private_dns_zone_ids = [
    module.private_dns.zone_ids["privatelink.blob.core.windows.net"]
  ]

  tags = {
    Owner = "CCOE"
  }
}
```

With `name` omitted, the module generates a name like `pep-platform-cc-dev-001`.

## App Service Private Endpoint

```hcl
module "app_private_endpoint" {
  source = "./modules/private_endpoint"

  name                           = "pep-app-cc-prod-001"
  resource_group_name            = "rg-app-prod"
  location                       = "canadacentral"
  subnet_id                      = module.vnet.subnet_ids["snet-private-endpoints"]
  private_connection_resource_id = module.appservice.id
  subresource_names              = ["sites"]

  private_dns_zone_names               = ["privatelink.azurewebsites.net"]
  private_dns_zone_resource_group_name = "rg-platform-dns"
}
```

## Static IP Configuration

```hcl
ip_configurations = [{
  name               = "blob"
  private_ip_address = "10.42.2.10"
  subresource_name   = "blob"
  member_name        = "blob"
}]
```
