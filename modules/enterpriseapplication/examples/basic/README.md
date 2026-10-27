# Basic Enterprise Application Example

Creates or adopts the service principal associated with an existing Microsoft Entra app registration and adds the Terraform caller as an owner.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="application_id=00000000-0000-0000-0000-000000000000"
```

Use the application/client ID, not the app registration object ID. Review owner governance and whether users must be explicitly assigned before applying in a production tenant.

## Cost and risk

- Free: it creates only an Entra service principal, with no Azure resources and no per-resource or per-request charge.
- Risk: the changes are tenant-wide directory objects, and the caller needs rights to manage service principals. `use_existing = true` adopts an existing service principal rather than failing, so a destroy removes one you did not create. `add_current_caller_as_owner = true` makes the deploying identity an owner, which may not suit pipeline identities. `app_role_assignment_required = false` lets any user in the tenant sign in to the application.
