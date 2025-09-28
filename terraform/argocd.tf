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
