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

## Cost and risk

- The Data Factory itself is free to hold; you pay per activity run and per integration-runtime hour. The default Azure integration runtime runs in a managed virtual network and bills per vCore-hour (General compute, 8 cores by default) only while pipelines or data flows use it; the 15-minute default time to live keeps a data flow cluster billed after it finishes.
- Public network access is disabled and this example creates no private endpoint, so the studio and API are unreachable until you add a private path. The managed virtual network setting cannot be changed in place, so changing it forces replacement.
