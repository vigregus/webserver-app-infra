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

# ----- Namespace -----
resource "kubernetes_namespace" "argocd" {
  metadata { name = "argocd" }
}

# ----- ArgoCD via Helm -----
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "6.7.12"

  set {
    name  = "crds.install"
    value = "true"
  }

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

resource "helm_release" "updater" {
  name = "updater"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-image-updater"
  namespace        = "argocd"
  create_namespace = true
  version          = "0.11.0"

  values     = [file("values/image-updater.yaml")]
  depends_on = [helm_release.argocd]
}

# ----- GitHub Repository Secret (with correct name) -----
resource "kubernetes_secret" "github_repo" {
  metadata {
    name      = "github-repo" # <-- Correct name
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  type = "Opaque"

  data = {
    type     = "git"
    url      = "https://github.com/vigregus/webserver-app-infra.git"
    name     = "webserver-app-infra"
    project  = "default"
    username = "vigregus"
    password = var.github_token
  }

  depends_on = [helm_release.argocd]
}

# ----- ImagePullSecret for GitHub Container Registry -----
resource "kubernetes_secret" "ghcr_secret" {
  metadata {
    name      = "ghcr-secret"
    namespace = kubernetes_namespace.argocd.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "ghcr.io" = {
          username = "vigregus"
          password = var.github_token
          email    = "vigregus@gmail.com"
          auth     = base64encode("vigregus:${var.github_token}")
        }
      }
    })
  }

  depends_on = [helm_release.argocd]
}

# ----- App of Apps -----
resource "kubernetes_manifest" "app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "webserver-app-of-apps"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/vigregus/webserver-app-infra.git"
        targetRevision = "main"
        path           = "gitops/1-root-apps"
        directory = {
          recurse = true
        }
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
          "CreateNamespace=true"
        ]
      }
    }
  }

  depends_on = [
    kubernetes_secret.github_repo,
    kubernetes_secret.ghcr_secret,
    helm_release.argocd
  ]
}

resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  namespace        = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  version          = "0.9.13"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  wait    = true
  timeout = 600
}

resource "time_sleep" "wait_external_secrets_crds" {
  depends_on      = [helm_release.external_secrets]
  create_duration = "30s"
}

# RBAC: allow ESO controller to read secrets in argocd
resource "kubernetes_role" "eso_read_secrets_argocd" {
  metadata {
    name      = "eso-read-secrets"
    namespace = "argocd"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "eso_read_secrets_argocd" {
  metadata {
    name      = "eso-read-secrets-binding"
    namespace = "argocd"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.eso_read_secrets_argocd.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "external-secrets"
    namespace = "external-secrets"
  }

  depends_on = [helm_release.external_secrets]
}

resource "kubernetes_manifest" "cluster_secret_store_k8s" {
  manifest = {
    apiVersion = "external-secrets.io/v1beta1"
    kind       = "ClusterSecretStore"
    metadata = {
      name = "k8s-store"
    }
    spec = {
      provider = {
        kubernetes = {
          auth = {
            serviceAccount = {
              name      = "external-secrets"
              namespace = "external-secrets"
            }
          }
          remoteNamespace = "argocd"
          # Add caBundle to bypass TLS validation
          server = {
            caProvider = {
              type      = "ConfigMap"
              name      = "kube-root-ca.crt"
              key       = "ca.crt"
              namespace = "kube-system"
            }
          }
        }
      }
    }
  }

  depends_on = [
    time_sleep.wait_external_secrets_crds,
    kubernetes_role_binding.eso_read_secrets_argocd
  ]
}
