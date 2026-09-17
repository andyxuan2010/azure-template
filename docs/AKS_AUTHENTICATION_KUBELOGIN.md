# AKS Authentication With `kubelogin`

## Summary

When running:

```powershell
az aks get-credentials -g rg-ccoe-iac-cc-sbx -n aks-iactest-sbx-901
```

the cluster credentials were merged into:

```text
%USERPROFILE%\.kube\config
```

but `kubectl` access was blocked with this message:

```text
The kubeconfig uses devicecode authentication which requires kubelogin.
Please install kubelogin from https://github.com/Azure/kubelogin or run
'az aks install-cli' to install both kubectl and kubelogin.
If devicecode login fails, try running
'kubelogin convert-kubeconfig -l azurecli' to unblock yourself.
```

## Why This Happens

This AKS cluster is configured to use Microsoft Entra ID authentication.

`az aks get-credentials` only writes the Kubernetes context into kubeconfig. It does not complete the sign-in flow that `kubectl` needs later. For Entra ID-enabled AKS clusters, `kubectl` depends on the external `kubelogin` executable to obtain an access token.

Without `kubelogin`, the kubeconfig exists, but cluster authentication cannot complete.

This is why `kubelogin` is required here: the AKS cluster is AAD/Entra-enabled, so Kubernetes authentication is delegated to Azure identity rather than handled entirely by static kubeconfig credentials.

## What Changed

`az aks install-cli` was run to install the required client tools.

Command used:

```powershell
az aks install-cli
```

On this machine, `kubelogin.exe` was installed at:

```text
%USERPROFILE%\.azure-kubelogin\kubelogin.exe
```

The user `PATH` already includes:

```text
%USERPROFILE%\.azure-kubelogin
%USERPROFILE%\.azure-kubectl
```

## Why `kubelogin` Was Still Not Found

The most likely reason is that the current PowerShell session was opened before `az aks install-cli` updated the user `PATH`.

That means:

- `kubelogin.exe` is installed correctly
- the shell session does not yet see the updated `PATH`

## Resolution Steps

### 1. Install the required CLI helpers

```powershell
az aks install-cli
```

This installs `kubectl` and `kubelogin` for local AKS access.

### 2. Verify the binary exists

```powershell
& "$env:USERPROFILE\.azure-kubelogin\kubelogin.exe" --version
```

If that works, the installation succeeded.

### 3. Refresh `PATH` or open a new shell

Simplest option:

```powershell
kubelogin --version
```

in a newly opened PowerShell window.

If staying in the current shell, refresh `PATH` manually:

```powershell
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
kubelogin --version
```

### 4. Convert kubeconfig to use Azure CLI login

To avoid the device code flow and reuse the current `az login` session:

```powershell
kubelogin convert-kubeconfig -l azurecli
```

This updates the kubeconfig exec authentication flow to use Azure CLI tokens instead of device code.

### 5. Test cluster access

```powershell
kubectl config current-context
kubectl get nodes
```

## Recommended Working Sequence

```powershell
az login
az aks get-credentials -g rg-ccoe-iac-cc-sbx -n aks-iactest-sbx-901
$env:Path = [Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [Environment]::GetEnvironmentVariable('Path','User')
kubelogin convert-kubeconfig -l azurecli
kubectl get nodes
```

## Notes

- `az aks get-credentials` succeeded. The issue was not with cluster retrieval.
- The blocker was local client authentication for `kubectl`.
- Azure RBAC access to the subscription does not by itself remove the need for `kubelogin` when the cluster is Entra ID-enabled.

## If `kubectl` Returns `Forbidden`

After `kubelogin` is working and private-cluster DNS/network access is in place, you can still see an error like:

```text
Error from server (Forbidden): nodes is forbidden: User "<object-id>" cannot list resource "nodes" in API group "" at the cluster scope: User does not have access to the resource in Azure. Update role assignment to allow access.
```

This means authentication succeeded, but Azure RBAC for Kubernetes Authorization is denying the identity access to the cluster data plane.

Important distinction:

- `Contributor` on the subscription or resource group is not enough for `kubectl get nodes`
- the identity needs an AKS Kubernetes RBAC role on the AKS cluster resource
- common choices are `Azure Kubernetes Service RBAC Cluster Admin` or `Azure Kubernetes Service RBAC Cluster Writer`

## New AKS Module Support In `template`

The `template/modules/aks` module now supports assigning the current Terraform execution identity an AKS Kubernetes RBAC role directly on the cluster.

New input:

```hcl
terraform_execution_aks_role = "Azure Kubernetes Service RBAC Cluster Admin"
```

Supported values:

- `Azure Kubernetes Service RBAC Cluster Admin`
- `Azure Kubernetes Service RBAC Cluster Writer`

This is intended for cases where the Terraform pipeline service principal needs to run `kubectl` against an Azure RBAC-enabled AKS cluster after deployment.

Example:

```hcl
module "aks" {
  source = "./modules/aks"

  resource_group_name           = "rg-example-prod"
  azure_rbac_enabled            = true
  terraform_execution_aks_role  = "Azure Kubernetes Service RBAC Cluster Admin"
}
```

This creates an Azure role assignment on the AKS cluster scope for the identity that Terraform is currently using.

## If The Cluster Was Not AAD/Entra-Enabled

If this were a non-AAD AKS cluster, the experience would usually be simpler:

- `az aks get-credentials` would still download and merge the kubeconfig
- `kubectl` would typically work immediately without `kubelogin`
- no `kubelogin convert-kubeconfig -l azurecli` step would normally be required

Typical flow for a non-AAD AKS cluster:

```powershell
az login
az aks get-credentials -g <resource-group> -n <cluster-name>
kubectl get nodes
```

In other words, the extra `kubelogin` dependency exists here specifically because the AKS cluster is using Microsoft Entra ID/AAD authentication.
