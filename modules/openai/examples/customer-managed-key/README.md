# Customer-Managed Key Azure OpenAI Example

Creates an Azure OpenAI account encrypted with an existing versioned Key Vault key and existing user-assigned identity. System-assigned identity remains enabled by default.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

Grant the identity the required Key Vault cryptographic permissions before apply, and coordinate key rotation and recovery. This example does not create private connectivity or model deployments.
