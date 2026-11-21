output "cluster_id" {
  description = "Resource ID of the AKS cluster."
  value       = module.aks.id
}

output "private_fqdn" {
  description = "Private API server FQDN."
  value       = module.aks.private_fqdn
}
