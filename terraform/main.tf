# This file has been refactored into separate files for better organization:
# - providers.tf    - Terraform providers configuration
# - argocd.tf       - ArgoCD namespace, helm releases, and App of Apps
# - secrets.tf      - GitHub repository and container registry secrets
# - external-secrets.tf - External Secrets Operator and RBAC
# - variables.tf    - Input variables (already exists)
