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

## Cost and risk

- The factory and runtime registration are billed per activity run. The main cost is the Windows VM, OS disk and network interface that the winvm module creates to host the runtime: VM size per hour, disk per GB-month, and Windows licensing unless covered by a benefit.
- The runtime authorization keys are written as secrets to the shared Key Vault, so the Terraform identity needs secret-write access there, and the VM needs a network route and DNS resolution to the factory, the data sources and the vault. The custom script extension installs and registers the runtime, so a failure there leaves a VM that exists but is not registered.
- Public network access is disabled with a managed virtual network. Deleting the runtime while pipelines still reference it breaks them, and secret deletion follows the soft-delete and purge-protection settings of the vault.
