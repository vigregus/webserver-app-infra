variable "kubeconfig" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "context" {
  description = "Kubernetes context name"
  type        = string
  default     = "minikube"
}

variable "github_token" {
  description = "GitHub Personal Access Token with repo, packages, and org permissions"
  type        = string
  sensitive   = true
}
