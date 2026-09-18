# Azure Container App

Provisions an Azure Container App in an existing managed environment with configurable revisions, containers, ingress, managed identity, secrets, registries, volumes, Dapr, and KEDA scaling.

## Features

- Supports multiple application and init containers.
- Supports single- and multiple-revision traffic models.
- Configures external or environment-internal ingress, traffic weights, CORS, and IP restrictions.
- Supports system-assigned and user-assigned managed identities.
- Integrates with container registries and Key Vault-backed secrets.
- Supports HTTP, TCP, Azure Queue, and custom KEDA scale rules.
- Supports Dapr, volumes, workload profiles, and lifecycle tuning.

## Resources Created

The module creates one `azurerm_container_app`. It may read the target resource group to resolve location or tags. The Container Apps managed environment, registries, Key Vault secrets, identities, storage, monitoring configuration, and network infrastructure are caller-owned.

Azure creates revisions and replicas as part of the Container App lifecycle; Terraform does not manage them as separate resources.

## Prerequisites and Dependencies

- An existing resource group.
- An existing Azure Container Apps managed environment.
- Accessible container images and any required registry identities or credentials.
- Existing Key Vault secrets and an identity with data-plane access when Key Vault references are used.
- Environment-level network, private DNS, logging, and workload-profile configuration.
- Terraform `>= 1.6.0` and AzureRM `>= 4.0, < 5.0`.

## Provider Configuration

Configure AzureRM in the calling root module:

```hcl
provider "azurerm" {
  features {}
}
```

The Terraform execution identity must be able to manage Container Apps. Runtime identities separately require access to registries, Key Vault, queues, and other application dependencies.

## Basic Usage

See the executable [basic example](examples/basic/), [complete example](examples/complete/), and [background worker example](examples/background-worker/).

```hcl
module "container_app" {
  source = "../../modules/containerapp"

  resource_group_name          = azurerm_resource_group.app.name
  container_app_environment_id = azurerm_container_app_environment.app.id
  name                         = "ca-payments-prod-001"

  containers = [{
    name   = "api"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.5
    memory = "1Gi"
  }]

  ingress = {
    external_enabled = true
    target_port      = 80
  }
}
```

## Important Behavior and Secure Defaults

- The default identity is system-assigned.
- Ingress defaults to `null`, so the application has no HTTP or TCP ingress unless configured.
- Minimum replicas default to zero. Set a nonzero minimum when cold starts or availability objectives require always-ready capacity.
- The sample container default is useful for evaluation only; production callers must supply an approved, version-pinned image.
- `max_replicas` must be greater than or equal to `min_replicas`.
- Multiple revision mode requires deliberate traffic management and cleanup of inactive revisions.
- Inline secret values are sensitive but still exist in Terraform state. Prefer Key Vault secret references and managed identities.

## Networking and Private Connectivity

Ingress visibility is controlled by `ingress.external_enabled`, but the managed environment determines the broader network boundary, internal load balancer behavior, egress, DNS, and private connectivity. This module does not modify the environment.

Use IP restrictions only as one layer of defense. Prefer HTTPS, authenticated application endpoints, and environment-level controls. Private registry access and runtime dependency routing must already be available from the managed environment.

## Identity and RBAC

The Container App can use system-assigned, user-assigned, combined, or no managed identity. User-assigned identity IDs must be provided when selected. Registry and Key Vault references can use managed identities, but this module does not create their RBAC assignments.

## Naming and Tagging

Set `name` explicitly or allow the module to generate one from workload, environment, location, and instance inputs. Explicit tags override inherited resource-group tags with matching keys.

## Testing

The unit test suite uses a mocked AzureRM provider:

```shell
terraform init -backend=false
terraform test
```

Validate each executable example independently before deployment.

## Known Limitations

- The module does not create or configure the managed environment.
- Custom domains, certificates, environment storage, environment diagnostics, and application-level observability are outside its scope.
- Registry, Key Vault, and KEDA dependency permissions must be granted separately.
- Image availability and runtime health cannot be verified by offline Terraform tests.

## Terraform Reference

The content below is generated from the module source. Do not edit it manually.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0, < 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0, < 5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_container_app.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_app) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_env"></a> [app\_env](#input\_app\_env) | Deployment environment used when name is not provided. | `string` | `"dev"` | no |
| <a name="input_azure_queue_scale_rules"></a> [azure\_queue\_scale\_rules](#input\_azure\_queue\_scale\_rules) | Azure Queue scale rules. | <pre>list(object({<br>    name         = string<br>    queue_name   = string<br>    queue_length = number<br>    authentication = optional(list(object({<br>      secret_name       = string<br>      trigger_parameter = string<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_container_app_environment_id"></a> [container\_app\_environment\_id](#input\_container\_app\_environment\_id) | Existing Azure Container Apps managed environment resource ID. | `string` | n/a | yes |
| <a name="input_containers"></a> [containers](#input\_containers) | Container definitions for the Container App. | <pre>list(object({<br>    name              = string<br>    image             = string<br>    cpu               = number<br>    memory            = string<br>    args              = optional(list(string), null)<br>    command           = optional(list(string), null)<br>    ephemeral_storage = optional(string, null)<br>    env = optional(list(object({<br>      name        = string<br>      value       = optional(string)<br>      secret_name = optional(string)<br>    })), [])<br>    volume_mounts = optional(list(object({<br>      name     = string<br>      path     = string<br>      sub_path = optional(string)<br>    })), [])<br>  }))</pre> | <pre>[<br>  {<br>    "cpu": 0.25,<br>    "image": "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest",<br>    "memory": "0.5Gi",<br>    "name": "app"<br>  }<br>]</pre> | no |
| <a name="input_cooldown_period_in_seconds"></a> [cooldown\_period\_in\_seconds](#input\_cooldown\_period\_in\_seconds) | Optional scaling cooldown period in seconds. | `number` | `null` | no |
| <a name="input_custom_scale_rules"></a> [custom\_scale\_rules](#input\_custom\_scale\_rules) | KEDA custom scale rules. | <pre>list(object({<br>    name             = string<br>    custom_rule_type = string<br>    metadata         = optional(map(string), {})<br>    identity_id      = optional(string)<br>    authentication = optional(list(object({<br>      secret_name       = string<br>      trigger_parameter = string<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_dapr"></a> [dapr](#input\_dapr) | Optional Dapr sidecar configuration. | <pre>object({<br>    app_id       = string<br>    app_port     = optional(number)<br>    app_protocol = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_http_scale_rules"></a> [http\_scale\_rules](#input\_http\_scale\_rules) | HTTP scale rules. | <pre>list(object({<br>    name                = string<br>    concurrent_requests = string<br>    authentication = optional(list(object({<br>      secret_name       = string<br>      trigger_parameter = string<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_identity_ids"></a> [identity\_ids](#input\_identity\_ids) | User-assigned managed identity IDs when identity\_type includes UserAssigned. | `list(string)` | `[]` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Managed identity type. Supported values are "SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned", or "None". | `string` | `"SystemAssigned"` | no |
| <a name="input_ingress"></a> [ingress](#input\_ingress) | Optional ingress configuration. Set to null for internal/background apps. | <pre>object({<br>    external_enabled           = optional(bool, false)<br>    target_port                = number<br>    transport                  = optional(string, "auto")<br>    allow_insecure_connections = optional(bool, false)<br>    client_certificate_mode    = optional(string)<br>    exposed_port               = optional(number)<br>    traffic_weight = optional(list(object({<br>      percentage      = number<br>      latest_revision = optional(bool)<br>      revision_suffix = optional(string)<br>      label           = optional(string)<br>    })), [])<br>    ip_security_restrictions = optional(list(object({<br>      name             = string<br>      action           = string<br>      ip_address_range = string<br>      description      = optional(string)<br>    })), [])<br>    cors = optional(object({<br>      allowed_origins           = optional(list(string), [])<br>      allowed_methods           = optional(list(string), [])<br>      allowed_headers           = optional(list(string), [])<br>      exposed_headers           = optional(list(string), [])<br>      allow_credentials_enabled = optional(bool, false)<br>      max_age_in_seconds        = optional(number)<br>    }))<br>  })</pre> | `null` | no |
| <a name="input_inherit_resource_group_tags"></a> [inherit\_resource\_group\_tags](#input\_inherit\_resource\_group\_tags) | Whether to merge tags from the target resource group into Container App resources. | `bool` | `true` | no |
| <a name="input_inherited_resource_group_tags"></a> [inherited\_resource\_group\_tags](#input\_inherited\_resource\_group\_tags) | Optional plan-known resource group tags supplied by the root composition. When null and inherit\_resource\_group\_tags is true, the module falls back to reading the resource group. | `map(string)` | `null` | no |
| <a name="input_init_containers"></a> [init\_containers](#input\_init\_containers) | Optional init container definitions. | <pre>list(object({<br>    name              = string<br>    image             = string<br>    cpu               = optional(number)<br>    memory            = optional(string)<br>    args              = optional(list(string), null)<br>    command           = optional(list(string), null)<br>    ephemeral_storage = optional(string, null)<br>    env = optional(list(object({<br>      name        = string<br>      value       = optional(string)<br>      secret_name = optional(string)<br>    })), [])<br>    volume_mounts = optional(list(object({<br>      name     = string<br>      path     = string<br>      sub_path = optional(string)<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_instance"></a> [instance](#input\_instance) | Instance identifier used when name is not provided. | `string` | `"001"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the Container App. Leave empty to use the resource group location. | `string` | `""` | no |
| <a name="input_location_code"></a> [location\_code](#input\_location\_code) | Optional short location code used when name is not provided. Leave empty to derive it from location. | `string` | `""` | no |
| <a name="input_max_inactive_revisions"></a> [max\_inactive\_revisions](#input\_max\_inactive\_revisions) | Optional maximum inactive revisions to retain. | `number` | `null` | no |
| <a name="input_max_replicas"></a> [max\_replicas](#input\_max\_replicas) | Maximum number of app replicas. | `number` | `1` | no |
| <a name="input_min_replicas"></a> [min\_replicas](#input\_min\_replicas) | Minimum number of app replicas. | `number` | `0` | no |
| <a name="input_name"></a> [name](#input\_name) | Optional Container App name override. Leave empty to generate one from the naming convention. | `string` | `""` | no |
| <a name="input_polling_interval_in_seconds"></a> [polling\_interval\_in\_seconds](#input\_polling\_interval\_in\_seconds) | Optional scaling polling interval in seconds. | `number` | `null` | no |
| <a name="input_registries"></a> [registries](#input\_registries) | Container registry credentials or managed identity references. | <pre>list(object({<br>    server               = string<br>    username             = optional(string)<br>    password_secret_name = optional(string)<br>    identity             = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group where the Container App will be created. | `string` | n/a | yes |
| <a name="input_revision_mode"></a> [revision\_mode](#input\_revision\_mode) | Container App revision mode. Use Single for most apps, Multiple for blue/green or canary traffic splitting. | `string` | `"Single"` | no |
| <a name="input_revision_suffix"></a> [revision\_suffix](#input\_revision\_suffix) | Optional revision suffix. | `string` | `""` | no |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | Container App secrets. Use Key Vault secret IDs where possible. | <pre>list(object({<br>    name                = string<br>    value               = optional(string)<br>    key_vault_secret_id = optional(string)<br>    identity            = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags applied to the Container App. | `map(string)` | `{}` | no |
| <a name="input_tcp_scale_rules"></a> [tcp\_scale\_rules](#input\_tcp\_scale\_rules) | TCP scale rules. | <pre>list(object({<br>    name                = string<br>    concurrent_requests = string<br>    authentication = optional(list(object({<br>      secret_name       = string<br>      trigger_parameter = string<br>    })), [])<br>  }))</pre> | `[]` | no |
| <a name="input_termination_grace_period_seconds"></a> [termination\_grace\_period\_seconds](#input\_termination\_grace\_period\_seconds) | Optional container termination grace period in seconds. | `number` | `null` | no |
| <a name="input_volumes"></a> [volumes](#input\_volumes) | Optional template volumes. | <pre>list(object({<br>    name          = string<br>    storage_type  = string<br>    storage_name  = optional(string)<br>    mount_options = optional(string)<br>  }))</pre> | `[]` | no |
| <a name="input_workload"></a> [workload](#input\_workload) | Workload identifier used when name is not provided. | `string` | `"project"` | no |
| <a name="input_workload_profile_name"></a> [workload\_profile\_name](#input\_workload\_profile\_name) | Optional workload profile name in the Container Apps environment. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_app_environment_id"></a> [container\_app\_environment\_id](#output\_container\_app\_environment\_id) | Container Apps managed environment ID. |
| <a name="output_id"></a> [id](#output\_id) | Container App ID. |
| <a name="output_identity_type"></a> [identity\_type](#output\_identity\_type) | Managed identity type configured on the Container App. |
| <a name="output_latest_revision_fqdn"></a> [latest\_revision\_fqdn](#output\_latest\_revision\_fqdn) | Latest revision FQDN. |
| <a name="output_latest_revision_name"></a> [latest\_revision\_name](#output\_latest\_revision\_name) | Latest revision name. |
| <a name="output_location"></a> [location](#output\_location) | Resolved Azure region. |
| <a name="output_name"></a> [name](#output\_name) | Container App name. |
| <a name="output_outbound_ip_addresses"></a> [outbound\_ip\_addresses](#output\_outbound\_ip\_addresses) | Outbound IP addresses assigned to the Container App. |
| <a name="output_principal_id"></a> [principal\_id](#output\_principal\_id) | System-assigned managed identity principal ID when enabled. |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Resource group containing the Container App. |
| <a name="output_tags"></a> [tags](#output\_tags) | Effective tags applied to the Container App. |
<!-- END_TF_DOCS -->
