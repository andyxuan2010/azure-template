# AKS Workload Identity Example

Creates a user-assigned identity, trusts one exact Kubernetes service account through the AKS OIDC issuer, and grants one reviewed Azure role.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan -var-file="environment.tfvars"
```

The Kubernetes service account must also be annotated with the identity client ID, and the pod must opt into workload identity. Applying creates identity, federation, and RBAC resources; review the subject and role scope carefully.

## Cost and risk

- Free: the user-assigned identity, its federated credential and the role assignment have no charge; costs come only from the workloads that use them.
- Risk: the role assignment grants real access at `role_assignment_scope`, so a broad scope or a role such as Contributor or Owner can expose a lot of resources to anything that can obtain a token for the federated subject. The federated credential trusts one AKS issuer and one `system:serviceaccount:<namespace>:<name>` subject; an incorrect issuer or subject silently blocks token exchange, and changing them replaces the credential. Recreating the identity invalidates the credential and role assignments, and role assignments can take several minutes to propagate. Federated credentials on one identity are created one at a time, so adding many can slow apply.
