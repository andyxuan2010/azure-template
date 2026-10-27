# Customer-Managed Key Azure OpenAI Example

Creates an Azure OpenAI account encrypted with an existing versioned Key Vault key and existing user-assigned identity. System-assigned identity remains enabled by default.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

Grant the identity the required Key Vault cryptographic permissions before apply, and coordinate key rotation and recovery. This example does not create private connectivity or model deployments.

## Cost and risk

- Cost: the Azure OpenAI account (`S0` by default) has no standing charge by itself; usage is billed per model and token or provisioned capacity once deployments are called. This example creates no model deployments, private endpoint, or diagnostics. Key Vault key operations (wrap and unwrap) are billed on the existing vault, not by this example.
- Risk: the account has public network access off by default and key-based auth off (`local_auth_enabled = false`), so callers need Microsoft Entra roles and a private path; none is created here, so it is unreachable until you add one.
- Risk: the Key Vault key must be accessible to the identity before apply, otherwise creation fails. Disabling, deleting or losing access to the key makes the account unavailable, so use soft-delete and purge protection on the vault. The custom subdomain defaults to the account name and changing the name or subdomain replaces the account.
- Policy: organization policies that require CMK, disable local auth or deny public access can block or change these settings.
