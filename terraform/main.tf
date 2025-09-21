terraform {
  required_providers {
    kubernetes = { source = "hashicorp/kubernetes", version = "2.32.0" }
    helm       = { source = "hashicorp/helm", version = "2.13.2" }
  }
}

# ----- Providers -----
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

# ----- Namespace -----
resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

# ----- Argo CD via Helm (с установкой CRD) -----
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12" # при необходимости обнови до актуальной

  # Установить CRD из чарта (важно!)
  set {
    name  = "crds.install"
    value = "true"
  }

  # Небольшая настройка: позволяем HTTP в dev (удобно для port-forward)
  values = [<<-YAML
    configs:
      params:
        server.insecure: true
    server:
      service:
        type: ClusterIP
  YAML
  ]

  wait       = true
  depends_on = [kubernetes_namespace.argocd]
}

# ----- SSH ключ для GitHub -----
resource "kubernetes_secret" "github_ssh_key" {
  metadata {
    name      = "github-ssh-key"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    type          = base64encode("git")
    url           = base64encode("git@github.com:vigregus/webserver-app-infra.git")
    name          = base64encode("webserver-app-infra")
    project       = base64encode("default")
    sshPrivateKey = base64encode(var.github_ssh_private_key)
  }

  depends_on = [helm_release.argocd]
}

# ----- App of Apps для GitOps -----
resource "kubernetes_manifest" "webserver_app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "webserver-app-of-apps"
      namespace = kubernetes_namespace.argocd.metadata[0].name
      labels = {
        "app.kubernetes.io/name"    = "webserver-app-of-apps"
        "app.kubernetes.io/part-of" = "webserver-app"
        "app.kubernetes.io/type"    = "app-of-apps"
      }
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "git@github.com:vigregus/webserver-app-infra.git"
        targetRevision = "main"
        path           = "gitops"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = kubernetes_namespace.argocd.metadata[0].name
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "PrunePropagationPolicy=foreground",
          "PruneLast=true"
        ]
      }
      revisionHistoryLimit = 10
    }
  }

  depends_on = [kubernetes_secret.github_ssh_key]
}
