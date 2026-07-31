# Basic Enterprise Application Example

Creates or adopts the service principal associated with an existing Microsoft Entra app registration and adds the Terraform caller as an owner.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var="application_id=00000000-0000-0000-0000-000000000000"
```

Use the application/client ID, not the app registration object ID. Review owner governance and whether users must be explicitly assigned before applying in a production tenant.
