# Self-Hosted Integration Runtime Example

Creates Data Factory and enables the module's Windows VM-based self-hosted integration runtime composition.

This is an advanced scenario with a larger deployment and permission surface. It expects:

- existing application and shared IaC resource groups;
- an existing VNet and subnet;
- an existing shared Key Vault and storage account;
- permissions to create a Windows VM, extensions, secrets, and role assignments.

## Usage

Create a `.tfvars` file containing all required dependency names, then run:

```powershell
terraform init
terraform validate
terraform plan -var-file="shir.tfvars"
```

Review the Windows VM module documentation, bootstrap behavior, Key Vault permissions, network route, DNS resolution, and SHIR registration flow before applying.
