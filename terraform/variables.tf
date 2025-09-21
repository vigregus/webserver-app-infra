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
