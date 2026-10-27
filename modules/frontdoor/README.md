# Azure Front Door

Creates a Front Door Standard or Premium profile with one endpoint, origin group, origin, and HTTPS-first route. Premium profiles can optionally request a Private Link connection to a supported Azure origin.

## Features

- Supports Azure Front Door Standard and Premium tiers.
- Creates a default endpoint, origin group with health probes and load balancing, one origin, and one route.
- Redirects HTTP requests to HTTPS and forwards to the origin over HTTPS by default.
- Supports caller-owned custom domain IDs and optional Premium Private Link origins.
- Uses repository-style names, resource-group tag inheritance, and caller tag overrides.

## Resources Created

The module creates one `azurerm_cdn_frontdoor_profile`, `azurerm_cdn_frontdoor_endpoint`, `azurerm_cdn_frontdoor_origin_group`, `azurerm_cdn_frontdoor_origin`, and `azurerm_cdn_frontdoor_route`.

It does not create a custom domain, DNS records, WAF policy/security policy, diagnostics, or origin network restrictions.

## Prerequisites and Dependencies

- Existing resource group
- Reachable origin hostname and appropriate origin host header
- Supported origin TLS certificate when forwarding over HTTPS
- Premium tier, supported origin type and region, and manual approval at the origin for Private Link
- Custom domain resource IDs and DNS validation when associating caller-owned custom domains
- WAF policy and origin restrictions for production applications

## Provider Configuration

The caller supplies the default `azurerm` provider. The execution identity needs permission to manage Azure Front Door profile, endpoint, origin group, origin, and route resources in the target resource group. Private Link connections also require approval by an authorized owner of the target resource.

## Basic Usage

```hcl
module "frontdoor" {
  source = "./modules/frontdoor"

  name                = "afd-platform-prod-001"
  endpoint_name       = "afd-platform-prod-001"
  resource_group_name = "rg-edge-prod"
  origin_hostname     = "app.example.net"
  sku_name            = "Standard_AzureFrontDoor"

  workload = "platform"
  app_env  = "prod"
  tags     = { Owner = "CCOE" }
}
```

See [examples/basic](./examples/basic) and [examples/complete](./examples/complete).

## Important Behavior and Secure Defaults

- The default route accepts HTTP and HTTPS so it can redirect HTTP requests, then forwards traffic to the origin using HTTPS only.
- TLS certificate name checks are enabled by default. Set the origin host header to the hostname expected by the backend.
- Health probes use HTTPS `HEAD` requests to `/` by default. Configure the path and method to match an unauthenticated health endpoint on the origin.
- Azure Front Door is a public edge service. Restrict direct origin access so clients cannot bypass Front Door WAF, routing, or other edge controls. Use the `AzureFrontDoor.Backend` service tag and validate the `X-Azure-FDID` header where appropriate, or use Premium Private Link for supported origins.
- Private Link needs the Premium tier, supported origin types/regions, and manual approval. The managed connection is not usable until the target approves it.
- Front Door Standard and Premium have different costs and feature availability. Premium has a higher base cost but supports Private Link and full managed WAF capabilities.

## Custom Domains and WAF

Custom domain IDs can be attached to the route, but domain resources, managed TLS configuration, DNS records, and validation remain caller-managed. Set `link_to_default_domain = false` when associating custom domains without the default endpoint hostname. WAF policies and security policy associations are also managed separately; associate them with the endpoint/custom domains before production use.

## Naming and Tagging

Set `name` and globally unique `endpoint_name` explicitly or use generated names based on workload, environment, and instance. Caller tags override inherited resource-group tags on the profile and endpoint. See the repository [naming convention](../../docs/60-security-governance/naming-convention.md) and [tagging standard](../../docs/60-security-governance/tagging-standard.md).

## Architecture

See [Architecture](docs/architecture.md) for the profile, endpoint, route, origin group, and origin relationships.

## Testing

```powershell
terraform init -backend=false
terraform test -filter=tests/unit.tftest.hcl
```

The unit suite mocks AzureRM and uses plan-only assertions. It requires no Azure authentication and creates no resources.

## Known Limitations

- This module creates one origin and one route per module instance. Complex profiles with many routes or origin groups should use a shared-profile composition.
- It does not create WAF policies, custom domains, DNS records, diagnostics, or origin access restrictions.
- Caller-provided custom domain IDs, origin TLS, and backend connectivity are not discovered or validated against Azure.
- Private Link feature support varies by origin type and region, and approval is a separate operation.
- This module targets Front Door Standard/Premium; Azure Front Door Classic is not supported.

## Terraform Reference

The content below is generated by `terraform-docs`. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_cdn_frontdoor_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_endpoint) | resource |
| [azurerm_cdn_frontdoor_origin.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin) | resource |
| [azurerm_cdn_frontdoor_origin_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_origin_group) | resource |
| [azurerm_cdn_frontdoor_profile.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_profile) | resource |
| [azurerm_cdn_frontdoor_route.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/cdn_frontdoor_route) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_latency_in_milliseconds"></a> [additional\_latency\_in\_milliseconds](#input\_additional\_latency\_in\_milliseconds) | Latency tolerance used to group healthy origins for routing decisions. | `number` | `50` | no |
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when names are generated. | `string` | `"dev"` | no |
| <a name="input_cdn_frontdoor_custom_domain_ids"></a> [cdn\_frontdoor\_custom\_domain\_ids](#input\_cdn\_frontdoor\_custom\_domain\_ids) | Optional existing Front Door custom domain IDs to associate with the route. Domain resources and DNS validation remain caller-owned. | `list(string)` | `[]` | no |
| <a name="input_certificate_name_check_enabled"></a> [certificate\_name\_check\_enabled](#input\_certificate\_name\_check\_enabled) | Require the TLS certificate presented by the origin to match its configured host name. | `bool` | `true` | no |
| <a name="input_endpoint_enabled"></a> [endpoint\_enabled](#input\_endpoint\_enabled) | Whether the Front Door endpoint is enabled. | `bool` | `true` | no |
| <a name="input_endpoint_name"></a> [endpoint\_name](#input\_endpoint\_name) | Optional globally unique Front Door endpoint name. Leave empty to derive it from the profile name. | `string` | `""` | no |
| <a name="input_forwarding_protocol"></a> [forwarding\_protocol](#input\_forwarding\_protocol) | Protocol Front Door uses when forwarding requests to the origin. | `string` | `"HttpsOnly"` | no |
| <a name="input_health_probe_enabled"></a> [health\_probe\_enabled](#input\_health\_probe\_enabled) | Whether the origin group sends health probes. | `bool` | `true` | no |
| <a name="input_health_probe_interval_in_seconds"></a> [health\_probe\_interval\_in\_seconds](#input\_health\_probe\_interval\_in\_seconds) | Seconds between origin health probes. | `number` | `60` | no |
| <a name="input_health_probe_path"></a> [health\_probe\_path](#input\_health\_probe\_path) | Origin-relative health probe path. | `string` | `"/"` | no |
| <a name="input_health_probe_protocol"></a> [health\_probe\_protocol](#input\_health\_probe\_protocol) | Protocol used for origin health probes. | `string` | `"Https"` | no |
| <a name="input_health_probe_request_type"></a> [health\_probe\_request\_type](#input\_health\_probe\_request\_type) | HTTP method used for origin health probes. | `string` | `"HEAD"` | no |
| <a name="input_https_redirect_enabled"></a> [https\_redirect\_enabled](#input\_https\_redirect\_enabled) | Redirect HTTP requests to HTTPS. When enabled, both Http and Https must be in supported\_protocols. | `bool` | `true` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into the Front Door profile and endpoint. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and tag inheritance is enabled, the module reads the resource group. | `map(string)` | `null` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when names are generated. | `string` | `"001"` | no |
| <a name="input_link_to_default_domain"></a> [link\_to\_default\_domain](#input\_link\_to\_default\_domain) | Associate the route with the default Azure Front Door endpoint domain. Set false when using only custom domains. | `bool` | `true` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Front Door profile name. Leave empty to generate a name from the workload and environment. | `string` | `""` | no |
| <a name="input_origin_enabled"></a> [origin\_enabled](#input\_origin\_enabled) | Whether the origin is enabled. | `bool` | `true` | no |
| <a name="input_origin_group_name"></a> [origin\_group\_name](#input\_origin\_group\_name) | Optional origin group resource name. Leave empty to generate one from the profile. | `string` | `""` | no |
| <a name="input_origin_host_header"></a> [origin\_host\_header](#input\_origin\_host\_header) | Optional Host header sent to the origin. Defaults to origin\_hostname. | `string` | `null` | no |
| <a name="input_origin_hostname"></a> [origin\_hostname](#input\_origin\_hostname) | Backend origin host name without a scheme, port, or path. | `string` | n/a | yes |
| <a name="input_origin_http_port"></a> [origin\_http\_port](#input\_origin\_http\_port) | HTTP port used to reach the origin. | `number` | `80` | no |
| <a name="input_origin_https_port"></a> [origin\_https\_port](#input\_origin\_https\_port) | HTTPS port used to reach the origin. | `number` | `443` | no |
| <a name="input_origin_name"></a> [origin\_name](#input\_origin\_name) | Optional origin resource name. Leave empty to generate one from the profile. | `string` | `""` | no |
| <a name="input_origin_priority"></a> [origin\_priority](#input\_origin\_priority) | Origin priority within its group. Lower values receive traffic before higher values when healthy. | `number` | `1` | no |
| <a name="input_origin_weight"></a> [origin\_weight](#input\_origin\_weight) | Relative origin traffic weight within its group. | `number` | `500` | no |
| <a name="input_patterns_to_match"></a> [patterns\_to\_match](#input\_patterns\_to\_match) | URL path patterns handled by the route. | `list(string)` | <pre>[<br>  "/*"<br>]</pre> | no |
| <a name="input_private_link"></a> [private\_link](#input\_private\_link) | Optional Premium-only origin Private Link request. The target must be supported by Azure Front Door and the connection requires manual approval. | <pre>object({<br>    private_link_target_id = string<br>    location               = string<br>    request_message        = optional(string, "Access request for Azure Front Door Private Link Origin")<br>    target_type            = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Existing resource group where the Front Door profile will be created. | `string` | n/a | yes |
| <a name="input_restore_traffic_time_to_healed_or_new_endpoint_in_minutes"></a> [restore\_traffic\_time\_to\_healed\_or\_new\_endpoint\_in\_minutes](#input\_restore\_traffic\_time\_to\_healed\_or\_new\_endpoint\_in\_minutes) | Minutes before traffic is restored to a healed or new origin, where supported by the service. | `number` | `10` | no |
| <a name="input_route_enabled"></a> [route\_enabled](#input\_route\_enabled) | Whether the route is enabled. | `bool` | `true` | no |
| <a name="input_route_name"></a> [route\_name](#input\_route\_name) | Optional route resource name. Leave empty to generate one from the profile. | `string` | `""` | no |
| <a name="input_sample_size"></a> [sample\_size](#input\_sample\_size) | Number of health probe samples used for load-balancing decisions. | `number` | `4` | no |
| <a name="input_session_affinity_enabled"></a> [session\_affinity\_enabled](#input\_session\_affinity\_enabled) | Whether Front Door session affinity is enabled for the origin group. | `bool` | `false` | no |
| <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name) | Azure Front Door tier. Premium is required to use Private Link origins and provides managed WAF rule sets. | `string` | `"Standard_AzureFrontDoor"` | no |
| <a name="input_successful_samples_required"></a> [successful\_samples\_required](#input\_successful\_samples\_required) | Successful health probe samples required to consider an origin healthy. | `number` | `3` | no |
| <a name="input_supported_protocols"></a> [supported\_protocols](#input\_supported\_protocols) | Protocols accepted by the route. The default accepts HTTP for redirect and HTTPS for application traffic. | `list(string)` | <pre>[<br>  "Http",<br>  "Https"<br>]</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Front Door profile and endpoint. | `map(string)` | `{}` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used when names are generated. | `string` | `"project"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_host_name"></a> [endpoint\_host\_name](#output\_endpoint\_host\_name) | Default Azure Front Door endpoint host name. |
| <a name="output_endpoint_id"></a> [endpoint\_id](#output\_endpoint\_id) | Azure Front Door endpoint resource ID. |
| <a name="output_origin_group_id"></a> [origin\_group\_id](#output\_origin\_group\_id) | Azure Front Door origin group resource ID. |
| <a name="output_origin_id"></a> [origin\_id](#output\_origin\_id) | Azure Front Door origin resource ID. |
| <a name="output_profile_id"></a> [profile\_id](#output\_profile\_id) | Azure Front Door profile resource ID. |
| <a name="output_profile_name"></a> [profile\_name](#output\_profile\_name) | Azure Front Door profile name. |
| <a name="output_route_id"></a> [route\_id](#output\_route\_id) | Azure Front Door route resource ID. |
| <a name="output_sku_name"></a> [sku\_name](#output\_sku\_name) | Azure Front Door profile tier. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the profile and endpoint. |
<!-- END_TF_DOCS -->
