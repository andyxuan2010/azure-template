# Static Web App architecture

The module owns one `azurerm_static_web_app` resource in an existing resource group. It does not create the resource group, application source repository, deployment workflow, custom domains, DNS records, or application networking outside the Static Web App resource.

## Resource boundary

```text
Existing resource group
        |
        v
azurerm_static_web_app.this
  |- Free SKU by default
  |- optional repository deployment integration
  |- optional app settings and managed identity
  |- optional basic authentication
  `- inherited and caller-supplied tags
```

The module reads the resource group's location when `location` is empty and reads its tags when tag inheritance is enabled without plan-known tags. Supplying both `location` and `inherited_resource_group_tags` avoids those lookups during plan-only composition.

## Deployment and security considerations

- The Free plan is the default and does not create an App Service Plan.
- Repository integration requires all three values: `repository_url`, `repository_branch`, and `repository_token`. The token is sensitive and must be supplied through a secret store or protected pipeline variable.
- `api_key` is exposed as a sensitive output for deployment workflows. Do not print it in CI logs or commit it to source control.
- Public network access is enabled by default because Static Web Apps serve public web content. Set `public_network_access_enabled = false` only when the intended access pattern and service capabilities support it.
- Managed identity is opt-in. The module does not grant the identity permissions on other resources.
- Basic authentication is opt-in and should be paired with secret management and an explicit environment scope.

See the module [README](../README.md) for inputs, outputs, examples, and validation commands.
