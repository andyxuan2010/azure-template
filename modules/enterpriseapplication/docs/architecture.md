# Microsoft Entra Enterprise Application Architecture

```mermaid
flowchart LR
  Caller["Calling root module"] --> Module["enterpriseapplication module"]
  Module --> R1["azuread_service_principal"]
  Module --> R2["azuread_app_role_assignment"]
  Module --> R3["msgraph_update_resource"]
```

The enterpriseapplication module declares 3 managed resource type(s), including `azuread_service_principal`, `azuread_app_role_assignment`, `msgraph_update_resource`.

Resources that use `count` or `for_each` are gated by inputs such as `create_application_proxy`, `feature_tags`, `saml_relay_state`, `app_role_assignments`. Review those inputs to see which optional components a deployment creates.

The module accepts 16 input(s), with 1 required.
It returns 9 output(s), including `id`, `object_id`, `application_id`, `display_name`, `app_role_assignment_ids`, `application_proxy_enabled`. Pass these to downstream modules instead of recreating the resources in the caller.

The caller owns the surrounding infrastructure, such as the resource group, networks, identities, and key or log destinations that this module references. See the [module README](../README.md) for inputs and usage.
