# Logic App VNet Integration Example

Creates a private-by-default Logic App Standard host whose outbound traffic uses an existing delegated subnet with route-all enabled. It does not create an inbound private endpoint.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

Ensure DNS, routes, firewalls, storage endpoints, connector endpoints, and subnet capacity support all required outbound flows. Applying creates a billable Logic App Standard host.
