resource "azurerm_api_management" "this" {
  name                = local.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = var.sku_name

  public_network_access_enabled = var.public_network_access_enabled
  virtual_network_type          = var.virtual_network_type
  min_api_version               = var.min_api_version
  identity {
    type = "SystemAssigned"
  }

  dynamic "virtual_network_configuration" {
    for_each = var.subnet_id == null ? [] : [var.subnet_id]
    content {
      subnet_id = virtual_network_configuration.value
    }
  }

  protocols {
    enable_http2 = var.enable_http2
  }

  security {
    backend_ssl30_enabled                               = false
    backend_tls10_enabled                               = false
    backend_tls11_enabled                               = false
    frontend_ssl30_enabled                              = false
    frontend_tls10_enabled                              = false
    frontend_tls11_enabled                              = false
    triple_des_ciphers_enabled                          = false
    tls_ecdhe_ecdsa_with_aes128_cbc_sha_ciphers_enabled = false
    tls_ecdhe_ecdsa_with_aes256_cbc_sha_ciphers_enabled = false
    tls_ecdhe_rsa_with_aes128_cbc_sha_ciphers_enabled   = false
    tls_ecdhe_rsa_with_aes256_cbc_sha_ciphers_enabled   = false
    tls_rsa_with_aes128_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes128_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes128_gcm_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_cbc_sha256_ciphers_enabled      = false
    tls_rsa_with_aes256_cbc_sha_ciphers_enabled         = false
    tls_rsa_with_aes256_gcm_sha384_ciphers_enabled      = false
  }

  tags = local.tags

  lifecycle {
    precondition {
      condition     = contains(["None", "External", "Internal"], var.virtual_network_type)
      error_message = "virtual_network_type must be None, External, or Internal."
    }
    precondition {
      condition     = (var.virtual_network_type == "None") == (var.subnet_id == null)
      error_message = "Provide subnet_id exactly when virtual_network_type is External or Internal."
    }
  }
}
