# Management Group Architecture

Management groups form the tenant hierarchy above subscriptions. Policy and RBAC assigned at a parent can flow to every descendant.

```text
Tenant root group
  └─ Existing parent management group
       └─ Management group created by this module
            ├─ Associated subscription A
            └─ Associated subscription B
```

This module creates one node. Compose multiple module instances to build a hierarchy and use explicit dependencies when a child references a newly created parent.

## Stable Identity

`name` is the management group ID embedded in Azure resource IDs and downstream policy or role scopes. It should be concise, explicit, and stable. `display_name` is the human-readable label and can change independently.

Generated IDs include a random suffix and are more appropriate for temporary or isolated cases than permanent landing-zone anchors.

## Governance Inheritance

Moving a subscription changes the management groups above it and can therefore change:

- inherited policy and initiatives;
- inherited RBAC assignments;
- compliance results and remediation;
- allowed regions, SKUs, networking, security, and tagging requirements.

Subscription placement changes should be reviewed as governance changes, not simple organization changes.

## Ownership Boundary

This module does not create subscriptions, policies, assignments, roles, or child groups. Coordinate hierarchy ownership so only one Terraform state controls each management group and each subscription placement.

Azure Management Groups do not support ARM tags. The module's `tags` input is downstream metadata only.

## Lifecycle

Management group and subscription operations can be eventually consistent. Deletion requires child groups, subscriptions, policy assignments, and other dependencies to be moved or removed first. Use protected branches and reviewed plans for tenant-level changes.
