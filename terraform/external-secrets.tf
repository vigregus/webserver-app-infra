# ----- External Secrets Operator -----
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
