# Basic Automation Account Example

Creates an Automation Account with local authentication and public network access disabled and a system-assigned managed identity enabled.

This example intentionally does not create a private endpoint. The account is therefore not an operational connectivity pattern until the required private endpoint, DNS, network path, and worker design are added.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="resource_group_name=rg-operations-dev"
```

Applying changes an Azure Automation resource and may have service or execution costs. Confirm access recovery, network design, runbook ownership, identity permissions, and cleanup before apply.
