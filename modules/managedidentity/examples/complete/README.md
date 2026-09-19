# AKS Workload Identity Example

Creates a user-assigned identity, trusts one exact Kubernetes service account through the AKS OIDC issuer, and grants one reviewed Azure role.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

The Kubernetes service account must also be annotated with the identity client ID, and the pod must opt into workload identity. Applying creates identity, federation, and RBAC resources; review the subject and role scope carefully.
