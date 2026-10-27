# GitHub Workload Identity Example

Creates a Microsoft Entra application and a federated identity credential restricted to the `main` branch of one GitHub repository. It intentionally creates neither a service principal nor a client secret; create or manage the enterprise application separately if the workload needs Azure role assignments.

## Usage

```powershell
terraform init -backend=false
terraform validate
terraform plan `
  -var="github_organization=contoso" `
  -var="github_repository=platform-infrastructure"
```

Applying changes tenant directory state. Protect the referenced branch and workflow, review GitHub environment-based subjects when stronger deployment approval is needed, and scope any later Azure role assignment to least privilege.

## Cost and risk

- App registrations and federated credentials are free, so no billable resource is created.
- No service principal or client secret is created, so the application cannot receive Azure role assignments until you add a service principal. The credential trusts any workflow run GitHub issues a token for on refs/heads/main of the named repository, so anyone who can push to main can obtain tokens; branch protection is the control. The subject must match exactly or token exchange fails.
