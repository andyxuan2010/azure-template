# Basic Azure Data Factory Example

Creates Data Factory with:

- public network access disabled;
- an ADF managed virtual network;
- a default Azure integration runtime;
- a system-assigned managed identity.

This example does not create an ADF control-plane private endpoint. Add private connectivity before adopting it for a production authoring or management path.

## Usage

```powershell
terraform init
terraform validate
terraform plan -var="resource_group_name=rg-data-dev"
```
