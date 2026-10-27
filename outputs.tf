# output "rg-name" {
#   value = module.rg.name
# }
# output "vm-privateip" {
#   value = module.linuxvm.privateip
# }

# output "custom_command" {
#   value = module.linuxvm.custom_command
# }
# output "linuxvm-public-ip" {
#   value = module.linuxvm.public_ip
# }
# output "linuxvm-public-public_ip2" {
#   value = module.linuxvm.public_ip2
# }
# output "sqlmi_name" {
#   value = module.sqlmi_db.name
# }

# output "sqlmi_administrator_login" {
#   value = module.sqlmi_db.administrator_login
# }

# output "sqlmi_fqdn" {
#   value = module.sqlmi_db.fqdn
# }

# output "app-vm" {
#   value = module.vm.app_vm.name
# }

# output "azurerm_cognitive_account_name" {
#   value = azurerm_cognitive_account.cognitive-service.name
# }

# # Output the endpoint and private endpoint URL
# output "cognitive-service-endpoint" {
#   value = azurerm_cognitive_account.cognitive-service.endpoint
# }

# output "private_endpoint_url" {
#   value = azurerm_private_endpoint.edp-cognitive.custom_dns_configs[0].fqdn
# }

# output "private_endpoint_private_ips" {
#   value = azurerm_private_endpoint.edp-cognitive.custom_dns_configs[0].ip_addresses
# }

# output "app_registration_application_id" {
#   description = "Application (client) ID of the app registration created for App Service auth, if enabled."
#   value       = var.enable_app_registration_for_appservice ? module.app_registration[0].application_id : null
# }
#
# output "app_registration_application_object_id" {
#   description = "Object ID of the app registration created for App Service auth, if enabled."
#   value       = var.enable_app_registration_for_appservice ? module.app_registration[0].application_object_id : null
# }
#
# output "app_registration_client_secret" {
#   description = "Client secret created for the app registration, if enabled."
#   value       = var.enable_app_registration_for_appservice ? module.app_registration[0].client_secret : null
#   sensitive   = true
# }

