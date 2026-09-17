# Basic Azure AI Services Example

Creates an `AIServices` account with a system-assigned identity, public network access disabled, and local key authentication disabled.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-ai-dev"
```

The default name is illustrative and must be globally unique. This secure baseline has no private endpoint, so add private connectivity or another approved network design before expecting workloads to reach the service. Confirm regional service access, quota, and cost before apply.
