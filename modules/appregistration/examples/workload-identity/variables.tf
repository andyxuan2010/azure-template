variable "name" {
  description = "Display name of the workload identity application."
  type        = string
  default     = "appreg-github-platform-prod"
}

variable "github_organization" {
  description = "GitHub organization or owner in the federated credential subject."
  type        = string
}

variable "github_repository" {
  description = "GitHub repository name in the federated credential subject."
  type        = string
}
