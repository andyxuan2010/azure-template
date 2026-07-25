# Container App Examples

## Public HTTP App

```hcl
module "api" {
  source = "./modules/containerapp"

  resource_group_name          = "rg-platform-dev"
  location                     = "canadacentral"
  container_app_environment_id = module.containerapp_environment.id

  ingress = {
    external_enabled = true
    target_port      = 8080
  }

  containers = [{
    name   = "api"
    image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
    cpu    = 0.25
    memory = "0.5Gi"
  }]
}
```

With `name` omitted, the module generates a name like `ca-platform-cc-dev-001`.

## Internal Worker

```hcl
module "worker" {
  source = "./modules/containerapp"

  name                         = "ca-worker-cc-prod-001"
  resource_group_name          = "rg-platform-prod"
  location                     = "canadacentral"
  container_app_environment_id = module.containerapp_environment.id
  min_replicas                 = 1
  max_replicas                 = 5

  containers = [{
    name   = "worker"
    image  = "contoso.azurecr.io/worker:1.0.0"
    cpu    = 0.5
    memory = "1Gi"
    env = [{
      name        = "QUEUE_CONNECTION"
      secret_name = "queue-connection"
    }]
  }]

  secrets = [{
    name                = "queue-connection"
    key_vault_secret_id = module.keyvault.secret_ids["queue-connection"]
    identity            = "System"
  }]
}
```

## HTTP Scale Rule

```hcl
http_scale_rules = [{
  name                = "http"
  concurrent_requests = "100"
}]
```

## IP Restricted Ingress

```hcl
ingress = {
  external_enabled = true
  target_port      = 8080
  ip_security_restrictions = [{
    name             = "corporate"
    action           = "Allow"
    ip_address_range = "203.0.113.0/24"
  }]
}
```
