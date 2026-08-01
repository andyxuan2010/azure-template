# Basic Service Bus

Creates a Standard namespace with one queue and disables SAS/local authentication.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide an existing resource group and globally unique namespace name. Assign Azure Service Bus data-plane roles to application identities outside this example; the namespace is otherwise unusable by clients. Service Bus is billable and should be removed when no longer needed.
