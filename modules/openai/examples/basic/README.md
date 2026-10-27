# Basic Azure OpenAI Account Example

Creates an Azure OpenAI account with public access and local key authentication disabled and system-assigned identity enabled. It creates no model deployments or private endpoint.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-orders-dev"
```

The account is intentionally unreachable until private connectivity or an explicitly reviewed public-access pattern is composed. Applying creates a billable Azure OpenAI account and requires approved regional access.
