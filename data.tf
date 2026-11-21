# -------------------------------------------------------------------
# Root Data Sources
# -------------------------------------------------------------------
# The root harness keeps root-level lookups minimal. We only resolve the
# current subscription and tenant so callers can omit those values from
# terraform.tfvars and use the active Azure context instead.
# -------------------------------------------------------------------

data "azurerm_client_config" "current" {}
