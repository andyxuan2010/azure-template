# OpenAI Examples

## Basic Azure OpenAI Account

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "oai-example-prod-001"
  sku_name            = "S0"
}
```

## Account With Model Deployments

```hcl
module "openai" {
  source = "./modules/openai"

  resource_group_name = "rg-example-prod"
  location            = "eastus"
  name                = "oai-example-prod-001"
  sku_name            = "S0"

  deployments = {
    gpt4o-mini = {
      model_format  = "OpenAI"
      model_name    = "gpt-4o-mini"
      model_version = "2024-07-18"
      sku_name      = "Standard"
      sku_capacity  = 10
    }
    text-embedding-3-large = {
      model_format = "OpenAI"
      model_name   = "text-embedding-3-large"
      sku_name     = "Standard"
      sku_capacity = 10
    }
  }
}
```
