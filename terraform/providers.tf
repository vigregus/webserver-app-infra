terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "2.32.0" }
    helm       = { source = "hashicorp/helm", version = "2.13.2" }
    null       = { source = "hashicorp/null", version = "3.2.2" }
    time       = { source = "hashicorp/time", version = "0.11.0" }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig
  config_context = var.context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig
    config_context = var.context
  }
}
