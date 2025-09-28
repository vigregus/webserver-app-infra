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
