output "subnet_id" {
  description = "Delegated App Service subnet resource ID."
  value       = module.subnet.ids["app-service"]
}
