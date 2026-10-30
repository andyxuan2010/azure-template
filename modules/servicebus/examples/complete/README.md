# Complete Service Bus

Creates a Premium, private, Entra-authenticated namespace with a queue, topic, subscription, system identity, diagnostics, and optional control-plane group assignments.

Run `terraform init -backend=false` and `terraform validate` for local validation. Before apply, provide the existing endpoint subnet, Private DNS zone, monitoring workspace, and a globally unique name. Also configure DNS links and application data-plane RBAC. Premium Service Bus incurs material ongoing cost.
